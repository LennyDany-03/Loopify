export default function StreakCard({ label, value, icon }) {
  return (
    <div className="bg-[#111118] border border-white/[0.07] rounded-2xl p-5 text-center">
      <p className="text-3xl mb-2">{icon}</p>
      <p className="text-white text-3xl font-bold">{value}</p>
      <p className="text-zinc-500 text-xs uppercase tracking-widest mt-1">{label}</p>
    </div>
  );
}