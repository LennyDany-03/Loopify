"use client";

import { useMemo } from "react";

const MONTHS = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
const DAYS_LABEL = ["","Mon","","Wed","","Fri",""];

export default function HeatmapGrid({ data = [], color = "#7c6cfc" }) {
  // Group data into weeks (columns), each week has 7 days
  const { weeks, monthLabels } = useMemo(() => {
    if (!data.length) return { weeks: [], monthLabels: [] };

    // Pad the start so the first day lands on the correct weekday
    const firstDate   = new Date(data[0].date);
    const startOffset = firstDate.getDay(); // 0 = Sun
    const padded      = Array(startOffset).fill(null).concat(data);

    // Split into 7-day columns
    const cols = [];
    for (let i = 0; i < padded.length; i += 7) {
      cols.push(padded.slice(i, i + 7));
    }

    // Month label positions (which column does each month start at)
    const labels = [];
    let lastMonth = -1;
    cols.forEach((week, colIdx) => {
      const firstReal = week.find(Boolean);
      if (!firstReal) return;
      const m = new Date(firstReal.date).getMonth();
      if (m !== lastMonth) {
        labels.push({ col: colIdx, label: MONTHS[m] });
        lastMonth = m;
      }
    });

    return { weeks: cols, monthLabels: labels };
  }, [data]);

  function cellOpacity(count) {
    if (!count) return 0;
    return Math.min(0.15 + count * 0.85, 1);
  }

  if (!weeks.length) {
    return (
      <div className="text-zinc-600 text-sm text-center py-8">
        No checkin data yet
      </div>
    );
  }

  return (
    <div className="overflow-x-auto">
      <div className="inline-flex flex-col gap-1 min-w-max">

        {/* Month labels row */}
        <div className="flex gap-1 mb-1 pl-8">
          {weeks.map((_, colIdx) => {
            const label = monthLabels.find((m) => m.col === colIdx);
            return (
              <div key={colIdx} className="w-3 text-[9px] text-zinc-600 text-center">
                {label ? label.label : ""}
              </div>
            );
          })}
        </div>

        {/* Grid rows — 7 rows (Sun–Sat) */}
        <div className="flex gap-1">
          {/* Day-of-week labels */}
          <div className="flex flex-col gap-1 mr-1">
            {DAYS_LABEL.map((d, i) => (
              <div key={i} className="w-6 h-3 text-[9px] text-zinc-600 flex items-center justify-end pr-1">
                {d}
              </div>
            ))}
          </div>

          {/* Columns */}
          {weeks.map((week, colIdx) => (
            <div key={colIdx} className="flex flex-col gap-1">
              {Array(7).fill(null).map((_, rowIdx) => {
                const cell = week[rowIdx];
                if (!cell) {
                  // Empty padding cell
                  return <div key={rowIdx} className="w-3 h-3 rounded-sm bg-transparent" />;
                }
                const opacity = cellOpacity(cell.count);
                const title   = `${cell.date}${cell.count ? ` — ${cell.value ?? "done"}` : ""}`;
                return (
                  <div
                    key={rowIdx}
                    title={title}
                    className="w-3 h-3 rounded-sm transition-opacity cursor-default"
                    style={{
                      background: cell.count
                        ? color
                        : "rgba(255,255,255,0.04)",
                      opacity:    cell.count ? opacity : 1,
                    }}
                  />
                );
              })}
            </div>
          ))}
        </div>

        {/* Legend */}
        <div className="flex items-center gap-1.5 mt-2 pl-8">
          <span className="text-[10px] text-zinc-600">Less</span>
          {[0, 0.25, 0.5, 0.75, 1].map((op, i) => (
            <div
              key={i}
              className="w-3 h-3 rounded-sm"
              style={{
                background: op === 0 ? "rgba(255,255,255,0.04)" : color,
                opacity:    op === 0 ? 1 : 0.15 + op * 0.85,
              }}
            />
          ))}
          <span className="text-[10px] text-zinc-600">More</span>
        </div>

      </div>
    </div>
  );
}