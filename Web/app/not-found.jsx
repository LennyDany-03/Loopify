import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center p-4 relative overflow-hidden">
      
      {/* Background ambient glow */}
      <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-violet-600/10 rounded-full blur-[100px] pointer-events-none" />
      <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-indigo-600/10 rounded-full blur-[100px] pointer-events-none" />

      <div className="relative z-10 glass-card max-w-lg w-full p-10 md:p-14 text-center rounded-[2rem] border border-white/10 shadow-2xl animate-fade-up">

        {/* 404 Text Glow */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-48 h-48 bg-purple-500/20 blur-[64px] pointer-events-none" />

        <h1 className="text-8xl md:text-[10rem] font-black text-transparent bg-clip-text bg-gradient-to-br from-white via-violet-300 to-indigo-500 mb-4 drop-shadow-[0_0_32px_rgba(139,92,246,0.3)] leading-none select-none">
          404
        </h1>
        
        <h2 className="text-2xl font-bold text-white mb-4 tracking-tight">
          Lost in the loop?
        </h2>
        
        <p className="text-zinc-400 mb-10 text-sm md:text-base max-w-xs mx-auto leading-relaxed">
          The page you are looking for doesn't exist, has been moved, or you mistyped the address.
        </p>

        <Link href="/dashboard" className="group inline-flex items-center justify-center w-full sm:w-auto px-8 py-3.5 rounded-2xl bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white shadow-lg shadow-violet-500/25 hover:shadow-violet-500/40 hover:-translate-y-1 transition-all duration-300 font-semibold text-sm">
          Return to Dashboard
          <span className="ml-2 transition-transform duration-300 group-hover:translate-x-1">
            →
          </span>
        </Link>
      </div>

    </div>
  );
}
