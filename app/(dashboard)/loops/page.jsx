"use client";

import { useEffect, useState } from "react";
import useLoopStore from "@/lib/store/useLoopStore";
import LoopList from "@/components/loops/LoopList";
import LoopForm from "@/components/loops/LoopForm";
import Modal from "@/components/ui/Modal";
import Button from "@/components/ui/Button";
import Spinner from "@/components/ui/Spinner";

export default function LoopsPage() {
  const { loops, fetchLoops, createLoop, isLoading } = useLoopStore();
  const [showModal, setShowModal] = useState(false);
  const [search, setSearch] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("All");

  useEffect(() => {
    fetchLoops();
  }, []);

  const categories = ["All", ...new Set(loops.map((l) => l.category))];

  const filtered = loops.filter((l) => {
    const matchSearch = l.name.toLowerCase().includes(search.toLowerCase());
    const matchCat = categoryFilter === "All" || l.category === categoryFilter;
    return matchSearch && matchCat;
  });

  async function handleCreate(data) {
    const result = await createLoop(data);
    if (result.success) setShowModal(false);
  }

  if (isLoading && !loops.length) {
    return (
      <div className="flex items-center justify-center h-64">
        <Spinner />
      </div>
    );
  }

  return (
    <div className="max-w-5xl mx-auto space-y-6">

      {/* ── Header ────────────────────────────────────────── */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 animate-fade-up">
        <div>
          <h1 className="text-white text-2xl sm:text-3xl font-bold tracking-tight">My Loops</h1>
          <p className="text-zinc-500 text-sm mt-0.5">{loops.length} active loops</p>
        </div>
        <Button onClick={() => setShowModal(true)}>+ New Loop</Button>
      </div>

      {/* ── Filters ───────────────────────────────────────── */}
      <div className="flex flex-col sm:flex-row gap-3 animate-fade-up" style={{ animationDelay: '100ms' }}>
        {/* Search */}
        <div className="relative">
          <span className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-500 text-sm">🔍</span>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search loops..."
            className="glass-card text-white text-sm rounded-xl pl-9 pr-4 py-2.5 outline-none focus:border-violet-500 transition-colors placeholder:text-zinc-600 w-full sm:w-56"
          />
        </div>

        {/* Category pills */}
        <div className="flex flex-wrap gap-2">
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setCategoryFilter(cat)}
              className={`text-xs px-3 py-1.5 rounded-full border transition-all duration-200 ${
                categoryFilter === cat
                  ? "bg-gradient-to-r from-violet-600 to-purple-600 border-violet-600 text-white shadow-lg shadow-violet-500/20"
                  : "border-white/[0.07] text-zinc-400 hover:border-violet-500 hover:text-white"
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* ── Loop list ─────────────────────────────────────── */}
      {filtered.length === 0 ? (
        <div className="text-center py-20 animate-fade-up">
          <div className="w-20 h-20 mx-auto rounded-2xl bg-violet-600/10 border border-violet-500/20 flex items-center justify-center mb-5 animate-float">
            <span className="text-4xl">🔍</span>
          </div>
          <p className="text-white font-semibold text-lg">No loops found</p>
          <p className="text-zinc-500 text-sm mt-1.5">
            {search ? "Try a different search term" : "Create your first loop to get started"}
          </p>
        </div>
      ) : (
        <LoopList loops={filtered} showCheckin={false} />
      )}

      {/* ── Create loop modal ─────────────────────────────── */}
      <Modal
        open={showModal}
        onClose={() => setShowModal(false)}
        title="Create New Loop"
      >
        <LoopForm onSubmit={handleCreate} onCancel={() => setShowModal(false)} />
      </Modal>

    </div>
  );
}