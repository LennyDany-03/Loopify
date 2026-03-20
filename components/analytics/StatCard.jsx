const colorMap = {
  violet: { bg: "bg-violet-600/10", border: "border-violet-500/20", text: "text-violet-300" },
  teal:   { bg: "bg-teal-500/10",   border: "border-teal-500/20",   text: "text-teal-300"   },
  orange: { bg: "bg-orange-500/10", border: "border-orange-500/20", text: "text-orange-300" },
  yellow: { bg: "bg-yellow-500/10", border: "border-yellow-500/20", text: "text-yellow-300" },
  green:  { bg: "bg-green-500/10",  border: "border-green-500/20",  text: "text-green-300"  },
  red:    { bg: "bg-red-500/10",    border: "border-red-500/20",    text: "text-red-300"    },
};

export default function StatCard({ label, value, icon, color = "violet" }) {
  const c = colorMap[color] ?? colorMap.violet;

  return (
    <div className={`${c.bg} border ${c.border} rounded-2xl p-4 flex flex-col gap-3`}>
      {/* Icon */}
      <div className="flex items-center justify-between">
        <span className="text-2xl">{icon}</span>
        <span className={`text-xs font-medium uppercase tracking-widest ${c.text} opacity-60`}>
          {label}
        </span>
      </div>

      {/* Value */}
      <p className="text-white text-3xl font-bold tracking-tight">{value}</p>
    </div>
  );
}