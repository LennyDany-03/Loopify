"use client";

import { useEffect, useState } from "react";
import { analyticsAPI } from "@/lib/api";
import StatCard from "@/components/analytics/StatCard";
import Spinner from "@/components/ui/Spinner";
import useLoopStore from "@/lib/store/useLoopStore";
import {
  PieChart, Pie, Cell, Tooltip, ResponsiveContainer, Legend,
} from "recharts";

const COLORS = ["#7c6cfc", "#5eead4", "#fb923c", "#f472b6", "#4ade80", "#facc15"];

export default function AnalyticsPage() {
  const { summary, fetchSummary } = useLoopStore();

  const [completion, setCompletion]   = useState(null);
  const [categories, setCategories]   = useState([]);
  const [loading, setLoading]         = useState(true);
  const [days, setDays]               = useState(30);

  useEffect(() => {
    fetchSummary();
  }, []);

  useEffect(() => {
    async function load() {
      setLoading(true);
      try {
        const [compRes, catRes] = await Promise.all([
          analyticsAPI.completionRate(days),
          analyticsAPI.categoryBreakdown(),
        ]);
        setCompletion(compRes.data);
        setCategories(catRes.data.categories);
      } catch (e) {
        console.error(e);
      } finally {
        setLoading(false);
      }
    }
    load();
  }, [days]);

  return (
    <div className="max-w-5xl mx-auto space-y-8">

      {/* ── Header ────────────────────────────────────────── */}
      <div className="animate-fade-up">
        <h1 className="text-white text-2xl sm:text-3xl font-bold tracking-tight">Analytics</h1>
        <p className="text-zinc-500 text-sm mt-1">Your habit performance at a glance</p>
      </div>

      {/* ── Summary cards ─────────────────────────────────── */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 sm:gap-4 stagger-children">
        <StatCard label="Total Loops"      value={summary?.total_loops ?? 0}            icon="🔁" color="violet" />
        <StatCard label="Total Checkins"   value={summary?.total_checkins ?? 0}         icon="✅" color="teal" />
        <StatCard label="Best Streak"      value={`${summary?.best_streak_overall ?? 0}d`} icon="🔥" color="orange" />
        <StatCard label="On Streak Today"  value={summary?.loops_on_streak_today ?? 0}  icon="⚡" color="yellow" />
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-48"><Spinner /></div>
      ) : (
        <>
          {/* ── Completion rate ────────────────────────────── */}
          <div className="glass-card rounded-2xl p-5 sm:p-6 animate-fade-up" style={{ animationDelay: '200ms' }}>
            <div className="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-3">
              <h2 className="text-white font-semibold text-lg">Completion Rate</h2>
              <div className="flex gap-2">
                {[7, 30, 90].map((d) => (
                  <button
                    key={d}
                    onClick={() => setDays(d)}
                    className={`text-xs px-3 py-1.5 rounded-full border transition-all duration-200 ${
                      days === d
                        ? "bg-gradient-to-r from-violet-600 to-purple-600 border-violet-600 text-white shadow-lg shadow-violet-500/20"
                        : "border-white/[0.07] text-zinc-400 hover:border-violet-500"
                    }`}
                  >
                    {d}d
                  </button>
                ))}
              </div>
            </div>

            {/* Rate display */}
            <div className="flex flex-col sm:flex-row items-center gap-8">
              <div className="relative w-32 h-32 shrink-0">
                <svg viewBox="0 0 120 120" className="w-full h-full -rotate-90">
                  <circle cx="60" cy="60" r="50" fill="none" stroke="rgba(255,255,255,0.06)" strokeWidth="10" />
                  <circle
                    cx="60" cy="60" r="50"
                    fill="none"
                    stroke="url(#compGrad)"
                    strokeWidth="10"
                    strokeLinecap="round"
                    strokeDasharray={`${2 * Math.PI * 50}`}
                    strokeDashoffset={`${2 * Math.PI * 50 * (1 - (completion?.completion_rate_percent ?? 0) / 100)}`}
                    className="transition-all duration-700"
                  />
                  <defs>
                    <linearGradient id="compGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop offset="0%" stopColor="#7c6cfc" />
                      <stop offset="100%" stopColor="#5eead4" />
                    </linearGradient>
                  </defs>
                </svg>
                <div className="absolute inset-0 flex items-center justify-center">
                  <span className="text-white text-2xl font-bold">
                    {completion?.completion_rate_percent ?? 0}%
                  </span>
                </div>
              </div>

              <div className="flex flex-row sm:flex-col gap-6 sm:gap-3">
                <div>
                  <p className="text-zinc-500 text-xs uppercase tracking-wide">Actual</p>
                  <p className="text-white font-semibold text-lg">{completion?.actual_checkins ?? 0}</p>
                </div>
                <div>
                  <p className="text-zinc-500 text-xs uppercase tracking-wide">Expected</p>
                  <p className="text-white font-semibold text-lg">{completion?.expected_checkins ?? 0}</p>
                </div>
                <div>
                  <p className="text-zinc-500 text-xs uppercase tracking-wide">Period</p>
                  <p className="text-white font-semibold text-lg">Last {days}d</p>
                </div>
              </div>
            </div>
          </div>

          {/* ── Category breakdown ─────────────────────────── */}
          {categories.length > 0 && (
            <div className="glass-card rounded-2xl p-5 sm:p-6 animate-fade-up" style={{ animationDelay: '300ms' }}>
              <h2 className="text-white font-semibold text-lg mb-6">Checkins by Category</h2>
              <ResponsiveContainer width="100%" height={280}>
                <PieChart>
                  <Pie
                    data={categories}
                    dataKey="total"
                    nameKey="category"
                    cx="50%"
                    cy="50%"
                    outerRadius={90}
                    innerRadius={50}
                    paddingAngle={3}
                  >
                    {categories.map((_, i) => (
                      <Cell key={i} fill={COLORS[i % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip
                    contentStyle={{
                      background: "rgba(17,17,24,0.9)",
                      backdropFilter: "blur(12px)",
                      border: "1px solid rgba(255,255,255,0.07)",
                      borderRadius: 12,
                    }}
                    labelStyle={{ color: "#fff" }}
                    itemStyle={{ color: "#a1a1aa" }}
                  />
                  <Legend
                    iconType="circle"
                    iconSize={8}
                    formatter={(val) => <span style={{ color: "#a1a1aa", fontSize: 12 }}>{val}</span>}
                  />
                </PieChart>
              </ResponsiveContainer>
            </div>
          )}
        </>
      )}
    </div>
  );
}