const colorMap = {
  violet: { gradient: "from-violet-500/20 to-purple-500/10", border: "border-violet-500/20", text: "text-violet-300", iconBg: "bg-violet-500/20" },
  teal:   { gradient: "from-teal-500/20 to-cyan-500/10",     border: "border-teal-500/20",   text: "text-teal-300",   iconBg: "bg-teal-500/20" },
  orange: { gradient: "from-orange-500/20 to-amber-500/10",  border: "border-orange-500/20", text: "text-orange-300", iconBg: "bg-orange-500/20" },
  yellow: { gradient: "from-yellow-500/20 to-amber-500/10",  border: "border-yellow-500/20", text: "text-yellow-300", iconBg: "bg-yellow-500/20" },
  green:  { gradient: "from-green-500/20 to-emerald-500/10", border: "border-green-500/20",  text: "text-green-300",  iconBg: "bg-green-500/20" },
  red:    { gradient: "from-red-500/20 to-rose-500/10",      border: "border-red-500/20",    text: "text-red-300",    iconBg: "bg-red-500/20" },
};

export default function StatCard({ label, value, icon, color = "violet" }) {
  const c = colorMap[color] ?? colorMap.violet;

  return (
    <div
      className={`
        animate-fade-up glass-card rounded-2xl p-4 flex flex-col gap-3
        border ${c.border}
        transition-all duration-300
        hover:translate-y-[-2px] hover:shadow-lg
      `}
    >
      {/* Icon + label */}
      <div className="flex items-center justify-between">
        <div className={`w-10 h-10 rounded-xl ${c.iconBg} flex items-center justify-center`}>
          <span className="text-xl">{icon}</span>
        </div>
        <span className={`text-[10px] font-semibold uppercase tracking-widest ${c.text} opacity-70`}>
          {label}
        </span>
      </div>

      {/* Value */}
      <p className="text-white text-2xl sm:text-3xl font-bold tracking-tight">{value}</p>

      {/* Accent gradient line */}
      <div className={`h-0.5 w-full rounded-full bg-gradient-to-r ${c.gradient} opacity-60`} />
    </div>
  );
}