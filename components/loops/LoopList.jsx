import LoopCard from "./LoopCard";

export default function LoopList({ loops = [], todayCheckins = {}, showCheckin = true }) {
  if (!loops.length) {
    return (
      <div className="text-center py-20">
        <p className="text-5xl mb-4">🔁</p>
        <p className="text-white font-medium">No loops yet</p>
        <p className="text-zinc-500 text-sm mt-1">Create your first loop to start tracking</p>
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
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
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