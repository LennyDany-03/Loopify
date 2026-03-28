"use client";

import {
  BarChart, Bar, XAxis, YAxis, Tooltip,
  ResponsiveContainer, Cell,
} from "recharts";

function CustomTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null;
  return (
    <div className="bg-[#1a1a24] border border-white/[0.07] rounded-lg px-3 py-2 text-xs">
      <p className="text-zinc-400 mb-0.5">{label}</p>
      <p className="text-white font-semibold">{payload[0].value} checkin{payload[0].value !== 1 ? "s" : ""}</p>
    </div>
  );
}

export default function WeeklyChart({ data = [], color = "#7c6cfc" }) {
  if (!data.length) {
    return (
      <div className="text-zinc-600 text-sm text-center py-8">
        No weekly data yet
      </div>
    );
  }

  // Shorten week label: "2025-W12" → "W12"
  const chartData = data.map((d) => ({
    week:  d.week.split("-")[1] ?? d.week,
    count: d.count,
  }));

  const maxVal = Math.max(...chartData.map((d) => d.count), 1);

  return (
    <ResponsiveContainer width="100%" height={180}>
      <BarChart data={chartData} barCategoryGap="30%">
        <XAxis
          dataKey="week"
          tick={{ fill: "#52525b", fontSize: 11 }}
          axisLine={false}
          tickLine={false}
        />
        <YAxis
          allowDecimals={false}
          tick={{ fill: "#52525b", fontSize: 11 }}
          axisLine={false}
          tickLine={false}
          width={24}
          domain={[0, maxVal]}
        />
        <Tooltip
          content={<CustomTooltip />}
          cursor={{ fill: "rgba(255,255,255,0.03)", radius: 4 }}
        />
        <Bar dataKey="count" radius={[4, 4, 0, 0]} maxBarSize={32}>
          {chartData.map((entry, i) => (
            <Cell
              key={i}
              fill={color}
              opacity={entry.count === 0 ? 0.15 : 0.7 + (entry.count / maxVal) * 0.3}
            />
          ))}
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  );
}