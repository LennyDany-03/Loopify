"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import useLoopStore from "@/lib/store/useLoopStore";
import HeatmapGrid from "@/components/analytics/HeatmapGrid";
import WeeklyChart from "@/components/analytics/WeeklyChart";
import StreakCard from "@/components/analytics/StreakCard";
import SlideToComplete from "@/components/loops/SlideToComplete";
import LoopForm from "@/components/loops/LoopForm";
import Modal from "@/components/ui/Modal";
import Button from "@/components/ui/Button";
import Spinner from "@/components/ui/Spinner";
import { analyticsAPI } from "@/lib/api";

export default function LoopDetailPage() {
  const { id } = useParams();
  const router = useRouter();

  const { loops, fetchLoops, updateLoop, deleteLoop, checkinLoop, todayCheckins, fetchTodayCheckins } = useLoopStore();
  const loop = loops.find((l) => l.id === id);

  const [heatmap, setHeatmap]     = useState([]);
  const [weekly, setWeekly]       = useState([]);
  const [streakData, setStreakData]= useState(null);
  const [loading, setLoading]     = useState(true);
  const [showEdit, setShowEdit]   = useState(false);
  const [showDelete, setShowDelete] = useState(false);

  // Fetch loops + today's checkins so page works on direct load / reload
  useEffect(() => {
    fetchLoops();
    fetchTodayCheckins();
  }, []);

  useEffect(() => {
    if (!id) return;
    async function loadAnalytics() {
      setLoading(true);
      try {
        const [heatRes, weekRes, streakRes] = await Promise.all([
          analyticsAPI.heatmap(id),
          analyticsAPI.weekly(id),
          analyticsAPI.streak(id),
        ]);
        setHeatmap(heatRes.data.heatmap);
        setWeekly(weekRes.data.weeks);
        setStreakData(streakRes.data);
      } catch (e) {
        console.error(e);
      } finally {
        setLoading(false);
      }
    }
    loadAnalytics();
  }, [id]);

  async function handleUpdate(data) {
    await updateLoop(id, data);
    setShowEdit(false);
  }

  async function handleDelete() {
    await deleteLoop(id);
    router.push("/loops");
  }

  const isCheckedToday = !!todayCheckins[id];

  if (!loop) {
    return (
      <div className="flex items-center justify-center h-64">
        <Spinner />
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto space-y-6">

      {/* ── Header ────────────────────────────────────────── */}
      <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4 animate-fade-up">
        <div className="flex items-center gap-3">
          <div
            className="w-14 h-14 rounded-2xl flex items-center justify-center text-3xl shrink-0"
            style={{
              background: `linear-gradient(135deg, ${loop.color}22, ${loop.color}11)`,
              border: `1px solid ${loop.color}44`,
            }}
          >
            {loop.icon}
          </div>
          <div>
            <h1 className="text-white text-xl sm:text-2xl font-bold">{loop.name}</h1>
            <div className="flex items-center gap-2 mt-1 flex-wrap">
              <span className="text-xs bg-white/[0.06] text-zinc-400 px-2 py-0.5 rounded-full">
                {loop.category}
              </span>
              <span className="text-xs bg-white/[0.06] text-zinc-400 px-2 py-0.5 rounded-full">
                {loop.frequency}
              </span>
              {loop.target_value && (
                <span className="text-xs bg-white/[0.06] text-zinc-400 px-2 py-0.5 rounded-full">
                  {loop.target_value} {loop.target_unit}
                </span>
              )}
            </div>
          </div>
        </div>

        {/* Actions */}
        <div className="flex items-center gap-2">
          <Button variant="ghost" onClick={() => setShowEdit(true)}>Edit</Button>
          <Button variant="danger" onClick={() => setShowDelete(true)}>Delete</Button>
        </div>
      </div>

      {/* ── Slide to Complete ─────────────────────────────── */}
      <div className="animate-fade-up" style={{ animationDelay: '80ms' }}>
        <SlideToComplete
          loopId={id}
          isChecked={isCheckedToday}
          onCheckin={checkinLoop}
          color={loop.color}
        />
      </div>

      {/* ── Streak cards row ──────────────────────────────── */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 sm:gap-4 stagger-children">
        <StreakCard label="Current Streak" value={loop.current_streak} icon="🔥" />
        <StreakCard label="Best Streak"    value={loop.best_streak}    icon="🏆" />
        <StreakCard label="Total Checkins" value={loop.total_checkins} icon="✅" />
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-40"><Spinner /></div>
      ) : (
        <>
          {/* ── Heatmap ─────────────────────────────────────── */}
          <div className="glass-card rounded-2xl p-4 sm:p-6 animate-fade-up" style={{ animationDelay: '200ms' }}>
            <h2 className="text-white font-semibold mb-4">
              {new Date().getFullYear()} Activity
            </h2>
            <HeatmapGrid data={heatmap} color={loop.color} />
          </div>

          {/* ── Weekly chart ────────────────────────────────── */}
          <div className="glass-card rounded-2xl p-4 sm:p-6 animate-fade-up" style={{ animationDelay: '300ms' }}>
            <h2 className="text-white font-semibold mb-4">Last 12 Weeks</h2>
            <WeeklyChart data={weekly} color={loop.color} />
          </div>
        </>
      )}

      {/* ── Edit modal ────────────────────────────────────── */}
      <Modal open={showEdit} onClose={() => setShowEdit(false)} title="Edit Loop">
        <LoopForm
          initialData={loop}
          onSubmit={handleUpdate}
          onCancel={() => setShowEdit(false)}
        />
      </Modal>

      {/* ── Delete confirm modal ──────────────────────────── */}
      <Modal open={showDelete} onClose={() => setShowDelete(false)} title="Delete Loop">
        <p className="text-zinc-400 text-sm mb-6">
          Are you sure you want to delete <span className="text-white font-medium">{loop.name}</span>?
          Your checkin history will be preserved.
        </p>
        <div className="flex gap-3">
          <Button variant="danger" onClick={handleDelete} className="flex-1">
            Yes, delete
          </Button>
          <Button variant="ghost" onClick={() => setShowDelete(false)} className="flex-1">
            Cancel
          </Button>
        </div>
      </Modal>

    </div>
  );
}