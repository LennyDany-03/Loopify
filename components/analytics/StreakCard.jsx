export default function StreakCard({ label, value, icon }) {
  return (
    <div className="animate-fade-up glass-card rounded-2xl p-5 text-center transition-all duration-300 hover:translate-y-[-2px] hover:shadow-lg hover:shadow-violet-500/5">
      <div className="w-12 h-12 mx-auto rounded-xl bg-white/[0.04] flex items-center justify-center mb-3">
        <span className="text-2xl">{icon}</span>
      </div>
      <p className="text-white text-2xl sm:text-3xl font-bold">{value}</p>
      <p className="text-zinc-500 text-[10px] uppercase tracking-widest mt-1.5">{label}</p>
    </div>
  );
}