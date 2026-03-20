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

      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-white text-2xl font-bold">My Loops</h1>
          <p className="text-zinc-500 text-sm mt-0.5">{loops.length} active loops</p>
        </div>
        <Button onClick={() => setShowModal(true)}>+ New Loop</Button>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3">
        {/* Search */}
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search loops..."
          className="bg-[#111118] border border-white/[0.07] text-white text-sm rounded-lg px-4 py-2 outline-none focus:border-violet-500 transition-colors placeholder:text-zinc-600 w-56"
        />

        {/* Category pills */}
        <div className="flex flex-wrap gap-2">
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setCategoryFilter(cat)}
              className={`text-xs px-3 py-1.5 rounded-full border transition-colors ${
                categoryFilter === cat
                  ? "bg-violet-600 border-violet-600 text-white"
                  : "border-white/[0.07] text-zinc-400 hover:border-violet-500 hover:text-white"
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* Loop list */}
      {filtered.length === 0 ? (
        <div className="text-center py-20">
          <p className="text-5xl mb-4">🔁</p>
          <p className="text-white font-medium">No loops found</p>
          <p className="text-zinc-500 text-sm mt-1">
            {search ? "Try a different search" : "Create your first loop to get started"}
          </p>
        </div>
      ) : (
        <LoopList loops={filtered} showCheckin={false} />
      )}

      {/* Create loop modal */}
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