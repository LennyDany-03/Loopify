import LoopCard from "./LoopCard";

export default function LoopList({ loops = [], todayCheckins = {}, showCheckin = true }) {
  if (!loops.length) {
    return (
      <div className="text-center py-20 animate-fade-up">
        <div className="w-20 h-20 mx-auto rounded-2xl bg-violet-600/10 border border-violet-500/20 flex items-center justify-center mb-5 animate-float">
          <span className="text-4xl">🔁</span>
        </div>
        <p className="text-white font-semibold text-lg">No loops yet</p>
        <p className="text-zinc-500 text-sm mt-1.5 max-w-xs mx-auto">
          Create your first loop and start building powerful habits
        </p>
      </div>
    );
  }

  // Sort: unchecked first, then checked — so done loops sink to the bottom
  const sorted = [...loops].sort((a, b) => {
    const aChecked = !!todayCheckins[a.id];
    const bChecked = !!todayCheckins[b.id];
    if (aChecked === bChecked) return 0;
    return aChecked ? 1 : -1;
  });

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 stagger-children">
      {sorted.map((loop) => (
        <LoopCard
          key={loop.id}
          loop={loop}
          isCheckedToday={!!todayCheckins[loop.id]}
          showCheckin={showCheckin}
        />
      ))}
    </div>
  );
}