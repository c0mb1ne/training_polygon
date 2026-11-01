//=============================================================================
// graph.js
// Reusable multi-series line graph. Works in menus (static data) and in the
// in-game HUD (live data that scrolls, e.g. accuracy per shot).
//
// Usage - static (menu, result screens):
//   var graph = CreateGraph($('#graphContainer'), {
//       title: 'Accuracy',
//       plotWidth: 560, plotHeight: 220,
//       yMin: 0, yMax: 100, yUnit: '%',
//       series: [ { id: 'acc', name: 'Accuracy', color: '#9CDBEE' } ]
//   });
//   graph.SetData({ acc: [50, 62, 70, 66, 81] });
//
// Usage - live (HUD):
//   var graph = CreateGraph($('#hudGraph'), {
//       mode: 'live', windowSize: 40, hud: true,
//       yMin: 0, yMax: 100, yUnit: '%', legendValues: true,
//       series: [ { id: 'acc', name: 'Accuracy' } ]
//   });
//   graph.Push({ acc: 87 });          // call on every sample
//
// Methods:
//   graph.SetData(data)            replace all samples. data = { id: [values] } | [values per series] |
//                                  [{ id, name?, color?, values }]  (unknown ids are created on the fly)
//   graph.Push(values)             live: append ONE sample to every series. values = { id: v } | [v per series] | v
//                                  (missing / non-number = gap). Static mode: appends and re-fits the whole graph.
//   graph.Clear()                  drop all samples, keep the series
//   graph.SetOption(name, value)   change an option at runtime (see below)
//   graph.GetOption(name)
//   graph.SetSeriesVisible(id, bool)
//   graph.Fit()                    re-measure the plot (autoSize only); call after un-hiding a collapsed page
//   graph.GetPanel()               widget root panel (move / hide it)
//   graph.Destroy()
//
// Options (all optional):
//   mode           'static' | 'live'                        default 'static'
//   windowSize     live: samples visible at once            default 60
//   liveAlign      live: 'right' (newest on the right edge, like a monitor) | 'left' (fills from the left)
//   title          string, '#token' is localized            default ''
//   plotWidth/plotHeight   plot size in layout px           default 560 x 220
//   autoSize       true = fill the parent container (measured), plotWidth/Height are only the first guess
//   hud            true = no frame/background, ignores the mouse (for in-game HUD)
//   smooth         live: animate the scrolling              default false
//   showTitle, showGrid, showYAxis, showXAxis, showLegend   default true
//   legendPosition 'inside' (overlay, top-left of plot) | 'top' | 'bottom'     default 'inside'
//   legendValues   show the latest value next to each name  default false
//   legendToggle   click on a legend entry hides the series default true (ignored when hud)
//   yMin / yMax    number, or 'auto' (nice rounded scale).  default 0 / 'auto'
//   yTicks         number of y intervals                    default 4
//   yUnit, formatY(v)   label text; formatY wins            default '' / null
//   xTicks         number of x labels                       default 5
//   xStart, xStep  static: x value of the first sample / spacing           default 1 / 1
//                  live: spacing between samples, newest sample is 0       (labels read 0, -10, -20 ...)
//   xUnit, formatX(v)   label text; formatX wins            default '' / null
//   yAxisWidth     px reserved for y labels (CSS default 72)
//   series[]       { id, name, color, thickness (2), points (false), pointSize (6), visible (true) }
//
// Include this file's <scripts> in the host layout (like hero_picker.js); graph.css and
// graph.xml are loaded by the widget itself. Needs no server events.
//
// How it draws: Panorama has no canvas, so every segment between two samples is a thin
// Panel, stretched to the segment length and rotated around its left end. Panels are pooled
// in a ring, so a live Push() only touches the newest segment of each series and slides one
// container; a full re-layout happens only when the y scale (or size) changes.
//=============================================================================

const GRAPH_XML = 'file://{resources}/layout/custom_game/graph.xml';

// Direction of rotateZ(). If segments look mirrored upside-down in game, change to -1.
const GRAPH_ROTATE_SIGN = 1;

const GRAPH_COLORS = ['#9CDBEE', '#D1B560', '#36ab00', '#db0028', '#8EBDCB', '#7d8688'];
const GRAPH_NICE_STEPS = [1, 2, 2.5, 4, 5, 10];
// live: x is re-based every ~2 windows, so panel coordinates never exceed ~2 plot widths
const GRAPH_X_LABEL_HALF_WIDTH = 40; // half of .GraphXLabel width in graph.css
const GRAPH_Y_LABEL_HALF_HEIGHT = 9; // half of .GraphYLabel height in graph.css

var _graphInstanceCount = 0;

function _graphLoc(text) {
	if (typeof text === 'string' && text.charAt(0) === '#') {
		return $.Localize(text);
	}
	return text;
}

function _graphFmt(v) {
	return String(Math.round(v * 100) / 100);
}

function _graphR1(v) {
	return Math.round(v * 10) / 10;
}

// smallest "nice" step (1, 2, 2.5, 4, 5, 10 * 10^n) that is >= raw
function _graphNiceStep(raw) {
	if (!(raw > 0)) {
		return 1;
	}
	const p = Math.pow(10, Math.floor(Math.log(raw) / Math.LN10));
	const f = raw / p;
	for (let i = 0; i < GRAPH_NICE_STEPS.length; i++) {
		if (f <= GRAPH_NICE_STEPS[i] + 1e-9) {
			return GRAPH_NICE_STEPS[i] * p;
		}
	}
	return 10 * p;
}

function CreateGraph(parentPanel, opts) {
	const instanceId = 'graph_' + (_graphInstanceCount++);

	const o = Object.assign({
		mode: 'static',
		windowSize: 60,
		liveAlign: 'right',
		title: '',
		plotWidth: 560,
		plotHeight: 220,
		autoSize: false,
		hud: false,
		smooth: false,
		showTitle: true,
		showGrid: true,
		showYAxis: true,
		showXAxis: true,
		showLegend: true,
		legendPosition: 'inside',
		legendValues: false,
		legendToggle: true,
		yMin: 0,
		yMax: 'auto',
		yTicks: 4,
		yUnit: '',
		formatY: null,
		xTicks: 5,
		xStart: 1,
		xStep: 1,
		xUnit: '',
		formatX: null,
		yAxisWidth: 72
	}, opts || {});
	const seriesDefs = o.series || [];
	delete o.series;

	// ---- load the widget markup into its own container (same pattern as hero_picker) ----
	const root = $.CreatePanel('Panel', parentPanel, instanceId);
	root.BLoadLayout(GRAPH_XML, false, false);
	const find = function (cls) {
		return root.FindChildrenWithClassTraverse(cls)[0];
	};
	/* const widget = find('GraphWidget'); */
	const widget = root;
	const titleLabel = find('GraphTitle');
	const yCol = find('GraphYCol');
	const yAxis = find('GraphYAxis');
	const plot = find('GraphPlot');
	const gridPanel = find('GraphGrid');
	const scroll = find('GraphScroll');
	const xAxis = find('GraphXAxis');
	const legendBoxes = {
		inside: find('GraphLegendInside'),
		top: find('GraphLegendTop'),
		bottom: find('GraphLegendBottom')
	};

	// ---- state ----
	let destroyed = false;
	let plotW = Math.max(2, o.plotWidth);
	let plotH = Math.max(2, o.plotHeight);
	let step = 1;            // px between samples
	let capacity = 2;        // ring size (samples kept, also the number of pooled panels per series)
	let count = 0;           // samples pushed so far (absolute index of the next sample)
	let firstIdx = 0;        // absolute index of values[0] of every series
	let xBase = 0;           // absolute sample index drawn at x = 0 (kept small, see GRAPH_MAX_COORD)
	let scale = { lo: 0, hi: 1 };
	let stamp = 0;
	const series = [];

	// ---- helpers ----
	function isLive() {
		return o.mode === 'live';
	}
	function visibleSamples() {
		return Math.max(2, isLive() ? Math.floor(o.windowSize) : count);
	}
	function recalcCapacity() {
		capacity = isLive() ? visibleSamples() + 2 : visibleSamples();
		step = plotW / (visibleSamples() - 1);
	}
	function rebaseLimit() {
		return (visibleSamples() * 2 + 2) * step;
	}
	function valueAt(s, k) {
		const v = s.values[k - firstIdx];
		return (typeof v === 'number' && isFinite(v)) ? v : null;
	}
	function normalize(v) {
		if (typeof v === 'string' && v.trim() !== '') { v = Number(v); }
		return (typeof v === 'number' && isFinite(v)) ? v : null;
	}
	function yPx(v) {
		const span = scale.hi - scale.lo;
		let t = span > 0 ? (v - scale.lo) / span : 0;
		if (t < 0) { t = 0; }
		if (t > 1) { t = 1; }
		return plotH - t * plotH;
	}
	function formatY(v) {
		if (o.formatY) {
			return o.formatY(v);
		}
		return _graphFmt(v) + o.yUnit;
	}
	function formatX(v) {
		if (o.formatX) {
			return o.formatX(v);
		}
		return _graphFmt(v) + o.xUnit;
	}
	function xOffset() {
		if (!isLive() || count === 0) {
			return 0;
		}
		const off = plotW - (count - 1 - xBase) * step; // puts the newest sample on the right edge
		return o.liveAlign === 'left' ? Math.min(0, off) : off;
	}

	// ---- scale (y axis) ----
	function computeScale() {
		const autoMin = (o.yMin === 'auto');
		const autoMax = (o.yMax === 'auto');
		const ticks = Math.max(1, Math.floor(o.yTicks));
		let lo = autoMin ? 0 : Number(o.yMin);
		let hi = autoMax ? 1 : Number(o.yMax);

		if (autoMin || autoMax) {
			let dMin = Infinity;
			let dMax = -Infinity;
			for (let i = 0; i < series.length; i++) {
				const s = series[i];
				if (!s.visible) { continue; }
				for (let j = 0; j < s.values.length; j++) {
					const v = s.values[j];
					if (typeof v === 'number' && isFinite(v)) {
						if (v < dMin) { dMin = v; }
						if (v > dMax) { dMax = v; }
					}
				}
			}
			if (dMin === Infinity) {
				dMin = 0;
				dMax = 0;
			}
			if (autoMin) {
				// tight lower bound on a "nice" grid; flat data gets a range of its own magnitude
				let span = dMax - dMin;
				if (!(span > 0)) { span = Math.abs(dMin) || 1; }
				const st = _graphNiceStep(span / ticks);
				lo = Math.floor(dMin / st) * st;
			}
			if (autoMax) {
				let range = dMax - lo;
				if (!(range > 0)) { range = 1; }
				hi = lo + _graphNiceStep(range / ticks) * ticks;
			}
		}
		if (!(hi > lo)) {
			hi = lo + 1;
		}
		return { lo: lo, hi: hi };
	}

	// returns true when the scale changed (=> every segment must be re-placed)
	function applyScale() {
		const n = computeScale();
		const changed = (n.lo !== scale.lo || n.hi !== scale.hi);
		scale = n;
		if (changed) {
			buildYLabels();
		}
		return changed;
	}

	// ---- axes / grid ----
	function buildYLabels() {
		yAxis.RemoveAndDeleteChildren();
		const ticks = Math.max(1, Math.floor(o.yTicks));
		for (let i = 0; i <= ticks; i++) {
			const v = scale.lo + i * (scale.hi - scale.lo) / ticks;
			const y = plotH - i / ticks * plotH;
			const label = $.CreatePanel('Label', yAxis, '');
			label.AddClass('GraphYLabel');
			label.text = formatY(v);
			label.style.marginTop = _graphR1(y - GRAPH_Y_LABEL_HALF_HEIGHT) + 'px';
		}
	}

	function buildGrid() {
		gridPanel.RemoveAndDeleteChildren();
		const ticks = Math.max(1, Math.floor(o.yTicks));
		for (let i = 0; i <= ticks; i++) {
			const line = $.CreatePanel('Panel', gridPanel, '');
			line.AddClass('GraphGridH');
			if (i === 0) {
				line.AddClass('GraphGridBase');
			}
			const y = Math.min(plotH - 1, plotH - i / ticks * plotH);
			line.style.marginTop = _graphR1(y) + 'px';
		}
		const xt = Math.max(2, Math.floor(o.xTicks));
		for (let j = 1; j < xt - 1; j++) {
			const line = $.CreatePanel('Panel', gridPanel, '');
			line.AddClass('GraphGridV');
			line.style.marginLeft = _graphR1(j / (xt - 1) * plotW) + 'px';
		}
	}

	function buildXLabels() {
		xAxis.RemoveAndDeleteChildren();
		const xt = Math.max(2, Math.floor(o.xTicks));
		for (let j = 0; j < xt; j++) {
			const label = $.CreatePanel('Label', xAxis, '');
			label.AddClass('GraphXLabel');
			label.style.marginLeft = _graphR1(j / (xt - 1) * plotW - GRAPH_X_LABEL_HALF_WIDTH) + 'px';
		}
		updateXLabels();
	}

	function updateXLabels() {
		const labels = xAxis.Children();
		const xt = labels.length;
		const off = xOffset();
		for (let j = 0; j < xt; j++) {
			const t = xt > 1 ? j / (xt - 1) : 0;
			let v;
			if (isLive()) {
				// sample under this x position, relative to the newest one (= 0)
				const rel = ((t * plotW - off) / step) + xBase - (count - 1);
				v = Math.round(rel) * o.xStep;
			} else {
				v = o.xStart + Math.round(t * (visibleSamples() - 1)) * o.xStep;
			}
			labels[j].text = formatX(v + 0); // "+ 0" turns -0 into 0
		}
	}

	// ---- series geometry ----
	function createSeg(s) {
		const p = $.CreatePanel('Panel', s.layer, '');
		p.AddClass('GraphSeg');
		p.style.backgroundColor = s.color;
		p.style.height = s.thickness + 'px';
		p.style.borderRadius = (s.thickness / 2) + 'px';
		p.visible = false;
		return { panel: p, key: '', shown: false, stamp: 0 };
	}

	function createDot(s) {
		const p = $.CreatePanel('Panel', s.layer, '');
		p.AddClass('GraphDot');
		p.style.backgroundColor = s.color;
		p.style.width = s.pointSize + 'px';
		p.style.height = s.pointSize + 'px';
		p.style.borderRadius = (s.pointSize / 2) + 'px';
		p.visible = false;
		return { panel: p, key: '', shown: false, stamp: 0 };
	}

	function hideRec(rec) {
		if (rec && rec.shown) {
			rec.panel.visible = false;
			rec.shown = false;
			rec.key = '';
		}
	}

	// segment that ends at sample k (connects k-1 -> k)
	function placeSeg(s, k) {
		const slot = k % capacity;
		const a = valueAt(s, k - 1);
		const b = valueAt(s, k);
		let rec = s.segs[slot];
		if (k <= firstIdx || a === null || b === null) {
			hideRec(rec);
			return;
		}
		if (!rec) {
			rec = createSeg(s);
			s.segs[slot] = rec;
		}
		rec.stamp = stamp;

		const th = s.thickness;
		const x1 = (k - 1 - xBase) * step;
		const y1 = yPx(a);
		const dx = step;
		const dy = yPx(b) - y1;
		const len = Math.sqrt(dx * dx + dy * dy);
		const ux = dx / len;
		const uy = dy / len;
		// extended by th/2 on both ends -> round caps, joints between segments stay closed
		const sx = x1 - ux * th / 2;
		const sy = y1 - uy * th / 2 - th / 2;
		const ang = Math.atan2(dy, dx) * 180 / Math.PI * GRAPH_ROTATE_SIGN;

		const key = _graphR1(sx) + 'px ' + _graphR1(sy) + 'px 0px|' + _graphR1(len + th) + 'px|' + _graphR1(ang) + 'deg';
		if (key !== rec.key) {
			const parts = key.split('|');
			rec.panel.style.position = parts[0];
			rec.panel.style.width = parts[1];
			rec.panel.style.transform = 'rotateZ(' + parts[2] + ')';
			rec.key = key;
		}
		if (!rec.shown) {
			rec.panel.visible = true;
			rec.shown = true;
		}
	}

	function placeDot(s, k) {
		if (!s.points) {
			return;
		}
		const slot = k % capacity;
		const v = valueAt(s, k);
		let rec = s.dots[slot];
		if (v === null) {
			hideRec(rec);
			return;
		}
		if (!rec) {
			rec = createDot(s);
			s.dots[slot] = rec;
		}
		rec.stamp = stamp;
		const x = (k - xBase) * step - s.pointSize / 2;
		const y = yPx(v) - s.pointSize / 2;
		const key = _graphR1(x) + 'px ' + _graphR1(y) + 'px 0px';
		if (key !== rec.key) {
			rec.panel.style.position = key;
			rec.key = key;
		}
		if (!rec.shown) {
			rec.panel.visible = true;
			rec.shown = true;
		}
	}

	function applyOffset(instant) {
		const css = 'translateX(' + _graphR1(xOffset()) + 'px)';
		if (instant && o.smooth) {
			scroll.RemoveClass('GraphScrollSmooth');
			scroll.style.transform = css;
			$.Schedule(0.05, function () {
				if (!destroyed) {
					scroll.SetHasClass('GraphScrollSmooth', o.smooth);
				}
			});
		} else {
			scroll.style.transform = css;
		}
	}

	// re-place every sample of every series (scale / size / window changed)
	function redrawAll(instantOffset) {
		stamp++;
		for (let i = 0; i < series.length; i++) {
			const s = series[i];
			for (let k = firstIdx; k < count; k++) {
				placeSeg(s, k);
				placeDot(s, k);
			}
			// pooled panels that are no longer part of the window
			for (let j = 0; j < s.segs.length; j++) {
				if (s.segs[j] && s.segs[j].stamp !== stamp) { hideRec(s.segs[j]); }
			}
			for (let j = 0; j < s.dots.length; j++) {
				if (s.dots[j] && s.dots[j].stamp !== stamp) { hideRec(s.dots[j]); }
			}
		}
		applyOffset(instantOffset);
		updateXLabels();
		updateLegendValues();
	}

	// full relayout: sizes, scale, grid, labels, geometry
	function relayoutAll() {
		recalcCapacity();
		trimToCapacity();
		scroll.style.width = Math.ceil(rebaseLimit() + 4 * step + 100) + 'px';
		if (!o.autoSize) {
			plot.style.width = plotW + 'px';
			plot.style.height = plotH + 'px';
			yAxis.style.height = plotH + 'px';
			xAxis.style.width = plotW + 'px';
		}
		scale = computeScale();
		buildYLabels();
		buildGrid();
		buildXLabels();
		redrawAll(true);
	}

	function trimToCapacity() {
		const excess = (count - firstIdx) - capacity;
		if (excess > 0) {
			for (let i = 0; i < series.length; i++) {
				series[i].values.splice(0, excess);
			}
			firstIdx += excess;
		}
	}

	// ---- legend ----
	function updateLegendValues() {
		if (!o.legendValues) {
			return;
		}
		for (let i = 0; i < series.length; i++) {
			const s = series[i];
			let last = null;
			for (let k = s.values.length - 1; k >= 0; k--) {
				const v = s.values[k];
				if (typeof v === 'number' && isFinite(v)) { last = v; break; }
			}
			s.valueLabel.text = last === null ? '' : formatY(last);
		}
	}

	function buildLegend() {
		for (const key in legendBoxes) {
			legendBoxes[key].RemoveAndDeleteChildren();
		}
		const box = legendBoxes[o.legendPosition] || legendBoxes.inside;
		for (let i = 0; i < series.length; i++) {
			const s = series[i];
			const entry = $.CreatePanel('Button', box, '');
			entry.AddClass('GraphLegendEntry');
			entry.SetHasClass('GraphLegendOff', !s.visible);
			const sw = $.CreatePanel('Panel', entry, '');
			sw.AddClass('GraphLegendSwatch');
			sw.style.backgroundColor = s.color;
			const nameLabel = $.CreatePanel('Label', entry, '');
			nameLabel.AddClass('GraphLegendName');
			nameLabel.text = _graphLoc(s.name);
			const valueLabel = $.CreatePanel('Label', entry, '');
			valueLabel.AddClass('GraphLegendValue');
			s.entry = entry;
			s.valueLabel = valueLabel;
			if (o.legendToggle && !o.hud) {
				entry.SetPanelEvent('onactivate', function () {
					setSeriesVisible(s.id, !s.visible);
				});
			}
		}
		updateLegendValues();
	}

	// ---- series management ----
	function addSeries(def) {
		const idx = series.length;
		const s = {
			id: def.id !== undefined ? String(def.id) : 'series' + idx,
			name: def.name !== undefined ? def.name : (def.id !== undefined ? String(def.id) : 'series' + idx),
			color: def.color || GRAPH_COLORS[idx % GRAPH_COLORS.length],
			thickness: def.thickness || 2,
			points: !!def.points,
			pointSize: def.pointSize || 6,
			visible: def.visible !== false,
			values: [],
			segs: [],
			dots: [],
			layer: null,
			entry: null,
			valueLabel: null
		};
		// samples already pushed: this series has no data for them
		for (let k = firstIdx; k < count; k++) {
			s.values.push(null);
		}
		s.layer = $.CreatePanel('Panel', scroll, '');
		s.layer.AddClass('GraphSeriesLayer');
		s.layer.visible = s.visible;
		series.push(s);
		return s;
	}

	function findSeries(id) {
		for (let i = 0; i < series.length; i++) {
			if (series[i].id === String(id)) {
				return series[i];
			}
		}
		return null;
	}

	function setSeriesVisible(id, visible) {
		const s = findSeries(id);
		if (!s || s.visible === visible) {
			return;
		}
		s.visible = visible;
		s.layer.visible = visible;
		if (s.entry) {
			s.entry.SetHasClass('GraphLegendOff', !visible);
		}
		if (applyScale()) {
			redrawAll(false);
		}
	}

	// ---- data ----
	function normalizeDefs(data) {
		if (Array.isArray(data)) {
			if (data.length > 0 && typeof data[0] === 'object' && data[0] !== null && !Array.isArray(data[0])) {
				return data; // [{ id, values, ... }]
			}
			const out = [];
			for (let i = 0; i < data.length; i++) {
				out.push({ id: series[i] ? series[i].id : 'series' + i, values: data[i] });
			}
			return out; // [[values], [values]] in series order
		}
		const out = [];
		for (const id in data) {
			out.push({ id: id, values: data[id] });
		}
		return out; // { id: [values] }
	}

	function setData(data) {
		const defs = normalizeDefs(data || {});
		let n = 0;
		let created = false;
		for (let i = 0; i < defs.length; i++) {
			const d = defs[i];
			let s = d.id !== undefined ? findSeries(d.id) : null;
			if (!s) {
				s = addSeries(d);
				created = true;
			} else {
				if (d.name !== undefined) { s.name = d.name; created = true; }
				if (d.color) { s.color = d.color; created = true; }
			}
			const vals = d.values || [];
			s.values = [];
			for (let j = 0; j < vals.length; j++) {
				s.values.push(normalize(vals[j]));
			}
			if (vals.length > n) { n = vals.length; }
		}
		count = n;
		firstIdx = 0;
		xBase = 0;
		for (let i = 0; i < series.length; i++) {
			while (series[i].values.length < n) { series[i].values.push(null); }
		}
		recalcCapacity();
		trimToCapacity();
		if (isLive()) {
			xBase = firstIdx;
		}
		if (created) {
			rebuildSeriesStyle();
			buildLegend();
		}
		relayoutAll();
	}

	// colors of existing pooled panels changed (setData with new color/name)
	function rebuildSeriesStyle() {
		for (let i = 0; i < series.length; i++) {
			const s = series[i];
			s.layer.RemoveAndDeleteChildren();
			s.segs = [];
			s.dots = [];
		}
	}

	function push(values) {
		if (destroyed) {
			return;
		}
		if (series.length === 0) {
			addSeries({ id: 'series0' });
			buildLegend();
		}
		const isArr = Array.isArray(values);
		const isScalar = (typeof values === 'number' || values === null || values === undefined);
		for (let i = 0; i < series.length; i++) {
			let v = null;
			if (isScalar) {
				v = (i === 0) ? values : null;
			} else if (isArr) {
				v = values[i];
			} else {
				v = values[series[i].id];
			}
			series[i].values.push(normalize(v));
		}
		count++;

		if (!isLive()) {
			relayoutAll(); // static: every sample moves, re-fit
			return;
		}

		recalcCapacity();
		trimToCapacity();

		let rebased = false;
		if ((count - 1 - xBase) * step > rebaseLimit()) {
			xBase = firstIdx;
			rebased = true;
		}
		if (applyScale() || rebased) {
			redrawAll(rebased);
			return;
		}
		stamp++;
		const k = count - 1;
		for (let i = 0; i < series.length; i++) {
			placeSeg(series[i], k);
			placeDot(series[i], k);
		}
		applyOffset(false);
		updateXLabels();
		updateLegendValues();
	}

	function clear() {
		count = 0;
		firstIdx = 0;
		xBase = 0;
		for (let i = 0; i < series.length; i++) {
			series[i].values = [];
		}
		relayoutAll();
	}

	// ---- sizing ----
	function measure() {
		const w = plot.actuallayoutwidth / (plot.actualuiscale_x || 1);
		const h = plot.actuallayoutheight / (plot.actualuiscale_y || 1);
		return (w > 2 && h > 2) ? { w: w, h: h } : null;
	}

	function fit(tries) {
		if (destroyed || !o.autoSize) {
			return;
		}
		const m = measure();
		if (m) {
			if (Math.abs(m.w - plotW) > 0.5 || Math.abs(m.h - plotH) > 0.5) {
				plotW = m.w;
				plotH = m.h;
				relayoutAll();
			}
		} else if (tries > 0) {
			// layout not computed yet (or page collapsed) - try again shortly
			$.Schedule(0.1, function () { fit(tries - 1); });
		}
	}

	// ---- option switches ----
	function applyFlags() {
		widget.SetHasClass('GraphNoTitle', !o.showTitle || !o.title);
		widget.SetHasClass('GraphNoGrid', !o.showGrid);
		widget.SetHasClass('GraphNoYAxis', !o.showYAxis);
		widget.SetHasClass('GraphNoXAxis', !o.showXAxis);
		widget.SetHasClass('GraphNoLegend', !o.showLegend);
		widget.SetHasClass('GraphNoLegendValues', !o.legendValues);
		scroll.SetHasClass('GraphScrollSmooth', !!o.smooth && isLive());
		titleLabel.text = _graphLoc(o.title);
		yCol.style.width = o.yAxisWidth + 'px';
	}

	function setOption(name, value) {
		o[name] = value;
		switch (name) {
			case 'title': case 'showTitle': case 'showGrid': case 'showYAxis': case 'showXAxis':
			case 'showLegend': case 'smooth': case 'yAxisWidth':
				applyFlags();
				break;
			case 'legendValues':
				applyFlags();
				updateLegendValues();
				break;
			case 'legendPosition': case 'legendToggle':
				buildLegend();
				break;
			case 'plotWidth': case 'plotHeight':
				plotW = Math.max(2, o.plotWidth);
				plotH = Math.max(2, o.plotHeight);
				relayoutAll();
				break;
			case 'yMin': case 'yMax': case 'yTicks': case 'yUnit': case 'formatY':
			case 'xTicks': case 'xStart': case 'xStep': case 'xUnit': case 'formatX':
			case 'windowSize': case 'liveAlign': case 'mode':
				relayoutAll();
				updateLegendValues();
				break;
		}
	}

	// ---- init ----
	if (o.autoSize) {
		root.style.width = '100%';
		root.style.height = '100%';
		widget.AddClass('GraphAuto');
	}
	if (o.hud) {
		widget.RemoveClass('GraphSkin');
		widget.AddClass('GraphHud');
		root.hittest = false;
		root.hittestchildren = false;
	}
	for (let i = 0; i < seriesDefs.length; i++) {
		addSeries(seriesDefs[i]);
	}
	applyFlags();
	buildLegend();
	relayoutAll();
	if (o.autoSize) {
		fit(30);
	}

	return {
		GetPanel: function () {
			return root;
		},
		SetData: setData,
		Push: push,
		Clear: clear,
		SetOption: setOption,
		GetOption: function (name) {
			return o[name];
		},
		SetSeriesVisible: setSeriesVisible,
		Fit: function () {
			fit(30);
		},
		Destroy: function () {
			destroyed = true;
			root.DeleteAsync(0);
		}
	};
}
