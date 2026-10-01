import { useEffect, useRef, useState } from 'react'

type Task = {
  id: string
  name: string
  title: string
  worktree: string
  result: string
  step: number
  status: 'working' | 'completed' | 'stopped'
}

type Exchange = {
  id: number
  message: string
  reply: string
  tasks: Task[]
}

const initialExchange: Exchange = {
  id: 1,
  message: 'Fix the login bug and update the admin dashboard.',
  reply: "I'll split this into two tasks and run them in parallel.",
  tasks: [
    {
      id: 'bugs',
      name: 'agent-bugs',
      title: 'Fix login / authentication issue',
      worktree: 'play_slot_bugfix',
      result: 'Login issue fixed and tests passed.',
      step: 0,
      status: 'working',
    },
    {
      id: 'admin',
      name: 'agent-admin',
      title: 'Update admin dashboard',
      worktree: 'play_slot_admin',
      result: 'Admin dashboard updated.',
      step: 0,
      status: 'working',
    },
  ],
}

function Icon({ name, size = 20, strokeWidth = 1.7 }: { name: string; size?: number; strokeWidth?: number }) {
  const common = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth, strokeLinecap: 'round' as const, strokeLinejoin: 'round' as const, 'aria-hidden': true as const }
  if (name === 'arrow-left') return <svg {...common}><path d="m14.5 5-7 7 7 7" /></svg>
  if (name === 'arrow-up') return <svg {...common}><path d="M12 19V5m-6 6 6-6 6 6" /></svg>
  if (name === 'arrow-right') return <svg {...common}><path d="M5 12h14m-6-6 6 6-6 6" /></svg>
  if (name === 'plus') return <svg {...common}><path d="M12 5v14M5 12h14" /></svg>
  if (name === 'close') return <svg {...common}><path d="M18 6 6 18M6 6l12 12" /></svg>
  if (name === 'check') return <svg {...common}><path d="m5 12 4 4L19 6" /></svg>
  if (name === 'stop') return <svg {...common}><rect x="7" y="7" width="10" height="10" rx="1" /></svg>
  if (name === 'terminal') return <svg {...common}><rect x="3" y="4" width="18" height="16" rx="3" /><path d="m7 9 3 3-3 3m6 0h4" /></svg>
  if (name === 'new') return <svg {...common}><path d="M12 5H6a2 2 0 0 0-2 2v11a2 2 0 0 0 2 2h11a2 2 0 0 0 2-2v-6M15 4h5v5m0-5-9 9" /></svg>
  if (name === 'paperclip') return <svg {...common}><path d="m20.1 11.6-7.8 7.8a5.5 5.5 0 0 1-7.8-7.8l8.5-8.5a3.7 3.7 0 0 1 5.2 5.2l-8.6 8.6a1.9 1.9 0 0 1-2.7-2.7l7.8-7.8" /></svg>
  return null
}

function Mark({ small = false }: { small?: boolean }) {
  return (
    <span className={`flex shrink-0 items-center justify-center rounded-[11px] border border-[#353e50] bg-[#1b2535] text-[#8fb1ff] ${small ? 'h-8 w-8' : 'h-11 w-11'}`} aria-hidden="true">
      <svg width={small ? 17 : 23} height={small ? 17 : 23} viewBox="0 0 24 24" fill="none">
        <path d="M5 17.5 12 5l7 12.5M8 13.5h8" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
        <circle cx="19" cy="17.5" r="1.8" fill="currentColor" />
      </svg>
    </span>
  )
}

function makeExchange(message: string): Exchange {
  const lower = message.toLowerCase()
  const isTest = lower.includes('test')
  const isBug = lower.includes('bug') || lower.includes('fix')
  const name = isTest ? 'agent-tests' : isBug ? 'agent-bugs' : 'agent-build'
  const title = isTest ? 'Run project tests' : isBug ? 'Investigate and fix issue' : 'Implement requested changes'
  return {
    id: Date.now(),
    message,
    reply: "On it. I've delegated this to a coding agent in its own worktree.",
    tasks: [{ id: name, name, title, worktree: `play_slot_${isTest ? 'tests' : isBug ? 'bugfix' : 'feature'}`, result: isTest ? 'Tests completed successfully.' : isBug ? 'Issue fixed and checks passed.' : 'Changes implemented and verified.', step: 0, status: 'working' }],
  }
}

function TaskCard({ task, onClick }: { task: Task; onClick: () => void }) {
  return (
    <button onClick={onClick} className="group w-full rounded-[14px] border border-[#292d33] bg-[#181b20] px-4 py-[15px] text-left transition-colors hover:border-[#3d4759] hover:bg-[#1c2027] active:scale-[0.99]" aria-label={`View ${task.name} details`}>
      <div className="flex items-start gap-3">
        <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-[10px] border border-[#303741] bg-[#222832] text-[#a3b4d1]"><Icon name="terminal" size={17} /></div>
        <div className="min-w-0 flex-1">
          <div className="flex items-center justify-between gap-2">
            <span className="text-[13px] font-semibold tracking-[-0.01em] text-[#e7e9ed]">{task.name}</span>
            <Icon name="arrow-right" size={15} strokeWidth={1.5} />
          </div>
          <div className="mt-0.5 font-mono text-[10px] text-[#777e89]">{task.name}</div>
        </div>
      </div>
      <div className="mt-[15px] flex items-end justify-between gap-2">
        <div className="min-w-0 truncate text-[13px] font-medium text-[#d3d6dc]">{task.title}</div>
        <div className={`flex shrink-0 items-center gap-1.5 text-[11px] font-medium ${task.status === 'working' ? 'text-[#87aaff]' : task.status === 'completed' ? 'text-[#a6b9d9]' : 'text-[#8a8d96]'}`}>
          {task.status === 'working' ? <span className="h-[5px] w-[5px] rounded-full bg-[#7da4ff] shadow-[0_0_8px_#719aff]" /> : <Icon name={task.status === 'completed' ? 'check' : 'stop'} size={12} />}
          <span>{task.status === 'working' ? 'Working' : task.status === 'completed' ? 'Completed' : 'Stopped'}</span>
        </div>
      </div>
    </button>
  )
}

function AgentSheet({ task, onClose, onStop }: { task: Task; onClose: () => void; onStop: () => void }) {
  const lines = [
    'Inspecting repository...',
    task.id === 'admin' ? 'Checking dashboard components...' : 'Checking authentication...',
    'Updating files...',
    'Running flutter analyze...',
    task.status === 'completed' ? 'Tests passed.' : task.status === 'stopped' ? 'Agent stopped.' : 'Running checks...',
  ]

  useEffect(() => {
    const onKey = (event: KeyboardEvent) => { if (event.key === 'Escape') onClose() }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [onClose])

  return (
    <div className="absolute inset-0 z-30 flex items-end bg-black/70" onMouseDown={onClose}>
      <section role="dialog" aria-modal="true" aria-label={`${task.name} details`} onMouseDown={(event) => event.stopPropagation()} className="w-full rounded-t-[22px] border-t border-[#343941] bg-[#191c21] px-6 pb-[calc(28px+env(safe-area-inset-bottom))] pt-3 shadow-[0_-20px_80px_#0009]">
        <div className="mx-auto mb-6 h-1 w-9 rounded-full bg-[#515761]" />
        <div className="flex items-start justify-between">
          <div className="flex items-center gap-3"><div className="flex h-10 w-10 items-center justify-center rounded-xl border border-[#374153] bg-[#222b3b] text-[#94b3fa]"><Icon name="terminal" size={19} /></div><div><h2 className="text-[17px] font-semibold text-white">{task.name}</h2><p className="mt-0.5 text-xs text-[#8d949f]">{task.title}</p></div></div>
          <button onClick={onClose} aria-label="Close details" className="flex h-8 w-8 items-center justify-center rounded-full bg-[#292d34] text-[#b1b6bf] hover:text-white"><Icon name="close" size={16} /></button>
        </div>
        <div className="mt-7 space-y-2.5 font-mono text-[11px] text-[#a2a8b2]"><p><span className="text-[#6d7582]">Worktree:</span> <span className="text-[#d5d9e1]">{task.worktree}</span></p><p><span className="text-[#6d7582]">Branch:</span> <span className="text-[#d5d9e1]">{task.name}</span></p></div>
        <div className="mt-6 overflow-hidden rounded-xl border border-[#30343b] bg-[#101215]">
          <div className="flex h-9 items-center gap-1.5 border-b border-[#292d33] px-3.5"><i className="h-[6px] w-[6px] rounded-full bg-[#525960]" /><i className="h-[6px] w-[6px] rounded-full bg-[#525960]" /><i className="h-[6px] w-[6px] rounded-full bg-[#525960]" /><span className="ml-auto font-mono text-[10px] text-[#737a86]">agent output</span></div>
          <div className="space-y-2 px-4 py-4 font-mono text-[11px] leading-[1.5] text-[#aab2bf]">{lines.map((line, index) => <div key={line} className="flex gap-3"><span className="select-none text-[#4e617a]">{String(index + 1).padStart(2, '0')}</span><span className={index === lines.length - 1 && task.status === 'completed' ? 'text-[#8facf2]' : ''}>{line}</span></div>)}</div>
        </div>
        {task.status === 'working' && <button onClick={onStop} className="mt-6 flex h-11 w-full items-center justify-center gap-2 rounded-[11px] border border-[#3c4149] bg-[#252930] text-[13px] font-medium text-[#e3e5e8] hover:bg-[#30343b]"><Icon name="stop" size={15} />Stop Agent</button>}
      </section>
    </div>
  )
}

export default function App() {
  const [screen, setScreen] = useState<'projects' | 'chat'>('chat')
  const [exchanges, setExchanges] = useState<Exchange[]>([initialExchange])
  const [draft, setDraft] = useState('')
  const [selectedTask, setSelectedTask] = useState<{ exchangeId: number; taskId: string } | null>(null)
  const [attachment, setAttachment] = useState<string | null>(null)
  const fileInput = useRef<HTMLInputElement>(null)
  const scrollArea = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const timer = window.setInterval(() => {
      setExchanges((previous) => previous.map((exchange) => {
        const index = exchange.tasks.findIndex((task) => task.status === 'working')
        if (index === -1) return exchange
        return { ...exchange, tasks: exchange.tasks.map((task, taskIndex) => taskIndex !== index ? task : task.step >= 1 ? { ...task, step: 2, status: 'completed' } : { ...task, step: 1 }) }
      }))
    }, 6500)
    return () => window.clearInterval(timer)
  }, [])

  useEffect(() => {
    if (screen === 'chat' && scrollArea.current) scrollArea.current.scrollTop = scrollArea.current.scrollHeight
  }, [exchanges.length, screen])

  const currentTask = selectedTask ? exchanges.find((exchange) => exchange.id === selectedTask.exchangeId)?.tasks.find((task) => task.id === selectedTask.taskId) : undefined

  function send(message = draft) {
    const text = message.trim()
    if (!text) return
    setExchanges((previous) => [...previous, makeExchange(text)])
    setDraft('')
    setAttachment(null)
  }

  function stopAgent() {
    if (!selectedTask) return
    setExchanges((previous) => previous.map((exchange) => exchange.id !== selectedTask.exchangeId ? exchange : { ...exchange, tasks: exchange.tasks.map((task) => task.id === selectedTask.taskId ? { ...task, status: 'stopped' } : task) }))
    setSelectedTask(null)
  }

  return (
    <div className="flex min-h-[100dvh] justify-center bg-[#08090b] text-[#f2f3f5] antialiased">
      <div className="relative flex h-[100dvh] min-h-[600px] w-full max-w-[430px] flex-col overflow-hidden border-x border-[#1c1f24] bg-[#0e1013] shadow-[0_0_90px_#0008]">
        <div className="flex h-[51px] shrink-0 items-end justify-between px-[29px] pb-[9px] text-white" aria-hidden="true">
          <span className="text-[14px] font-semibold tracking-[0.01em]">9:41</span>
          <div className="flex items-center gap-[6px]"><svg width="17" height="12" viewBox="0 0 17 12" fill="currentColor"><rect x="1" y="8" width="2.5" height="3" rx=".5" /><rect x="5" y="6" width="2.5" height="5" rx=".5" /><rect x="9" y="3" width="2.5" height="8" rx=".5" /><rect x="13" y="1" width="2.5" height="10" rx=".5" /></svg><svg width="16" height="13" viewBox="0 0 16 13" fill="none"><path d="M1 4.5c4-4 10-4 14 0M3.5 7c2.6-2.6 6.4-2.6 9 0M6.3 9.4a2.4 2.4 0 0 1 3.4 0" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" /><circle cx="8" cy="11" r="1" fill="currentColor" /></svg><svg width="25" height="12" viewBox="0 0 25 12" fill="none"><rect x=".6" y=".6" width="21" height="10.8" rx="2.5" stroke="currentColor" strokeWidth="1.2" /><rect x="2.4" y="2.3" width="17.3" height="7.4" rx="1.2" fill="currentColor" /><path d="M23 4v4" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" /></svg></div>
        </div>

        {screen === 'projects' ? (
          <div className="flex flex-1 flex-col px-6 pt-[52px]">
            <Mark />
            <h1 className="mt-8 text-[32px] font-semibold leading-none tracking-[-0.055em] text-white">Buddy<span className="text-[#81a5fa]">.</span></h1>
            <p className="mt-3 text-[14px] text-[#8b929d]">Your AI development team</p>
            <div className="mt-[58px] flex items-center justify-between"><span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[#69717d]">Your projects</span><span className="font-mono text-[11px] text-[#656c76]">01 / 01</span></div>
            <button onClick={() => setScreen('chat')} className="mt-4 w-full rounded-[16px] border border-[#30353c] bg-[#191c21] p-5 text-left transition-colors hover:border-[#4a5670] hover:bg-[#20242b]">
              <div className="flex items-start justify-between"><div className="flex h-11 w-11 items-center justify-center rounded-xl border border-[#343b49] bg-[#252d3b] font-mono text-[17px] font-semibold tracking-[-0.06em] text-[#a8c0f7]">P<span className="text-[#7e9fe7]">.</span></div><span className="flex items-center gap-1.5 rounded-full border border-[#354235] bg-[#202820] px-2.5 py-1 text-[10px] font-medium text-[#a2c9a5]"><span className="h-1.5 w-1.5 rounded-full bg-[#8cba90]" />Mac Connected</span></div>
              <h2 className="mt-7 text-[21px] font-semibold tracking-[-0.035em]">PlaySlot</h2>
              <p className="mt-1.5 font-mono text-[11px] text-[#939aa5]">Flutter <span className="px-1 text-[#59616c]">·</span> Git <span className="px-1 text-[#59616c]">·</span> 3 worktrees</p>
              <div className="mt-7 flex items-center justify-between border-t border-[#30343a] pt-4"><span className="text-[12px] font-medium text-[#9cb9fc]">Open project</span><span className="text-[#9cb9fc]"><Icon name="arrow-right" size={17} /></span></div>
            </button>
            <div className="mt-auto pb-[calc(34px+env(safe-area-inset-bottom))] text-center font-mono text-[10px] tracking-[0.04em] text-[#555d68]">LOCAL WORKSPACE · READY TO DELEGATE</div>
          </div>
        ) : (
          <>
            <header className="flex h-[71px] shrink-0 items-center justify-between border-b border-[#22252a] px-5">
              <div className="flex min-w-0 items-center gap-3"><button onClick={() => setScreen('projects')} aria-label="Back to projects" className="-ml-1 flex h-9 w-8 items-center justify-start text-[#b1b7c1] hover:text-white"><Icon name="arrow-left" size={22} /></button><div><h1 className="text-[16px] font-semibold leading-tight tracking-[-0.025em]">PlaySlot</h1><p className="mt-[3px] font-mono text-[10px] text-[#6d7580]">WORKSPACE / PLAY_SLOT</p></div></div>
              <div className="flex items-center gap-3"><span className="flex items-center gap-1.5 text-[11px] font-medium text-[#a8b2be]"><span className="h-[5px] w-[5px] rounded-full bg-[#83c397]" />Connected</span><button onClick={() => { setExchanges([]); setDraft(''); setAttachment(null) }} aria-label="New conversation" title="New conversation" className="flex h-8 w-8 items-center justify-center rounded-lg text-[#89919d] hover:bg-[#20242b] hover:text-white"><Icon name="new" size={17} /></button></div>
            </header>

            <main ref={scrollArea} className="chat-scroll min-h-0 flex-1 overflow-y-auto px-5 pb-7 pt-6">
              {exchanges.length === 0 ? (
                <div className="flex h-full min-h-[400px] flex-col items-center justify-center pb-8 text-center"><Mark /><h2 className="mt-6 text-[21px] font-semibold tracking-[-0.035em]">What are we building today?</h2><p className="mt-2 max-w-[250px] text-[13px] leading-5 text-[#858c97]">Describe a task and let your AI team handle it.</p><div className="mt-8 flex flex-wrap justify-center gap-2">{['Fix a bug', 'Build a feature', 'Run tests'].map((suggestion) => <button key={suggestion} onClick={() => setDraft(suggestion)} className="rounded-full border border-[#30343b] bg-[#191c21] px-3 py-2 text-[11px] text-[#b8bdc6] hover:border-[#5974ab] hover:text-white">{suggestion}</button>)}</div></div>
              ) : (
                <div className="space-y-9">
                  {exchanges.map((exchange, exchangeIndex) => (
                    <div key={exchange.id} className="space-y-6">
                      {exchangeIndex === 0 && <div className="text-center font-mono text-[10px] tracking-[0.12em] text-[#666e79]">TODAY <span className="px-1.5 text-[#3f454f]">·</span> 09:41</div>}
                      <div className="flex justify-end"><div className="max-w-[86%] rounded-[16px] rounded-br-[5px] border border-[#333842] bg-[#252a33] px-4 py-3.5 text-[13px] leading-[1.6] text-[#edf0f4]">{exchange.message}</div></div>
                      <div className="flex items-start gap-3"><Mark small /><div className="min-w-0 flex-1 pt-0.5"><div className="flex items-center gap-2"><span className="text-[12px] font-semibold text-[#e3e6ed]">Buddy</span><span className="rounded-[4px] border border-[#343b4b] bg-[#1b2433] px-1.5 py-0.5 font-mono text-[9px] font-medium text-[#9cb6ed]">LEAD</span></div><p className="mt-2.5 max-w-[285px] text-[13px] leading-[1.6] text-[#cbd0d8]">{exchange.reply}</p></div></div>
                      <div className="pl-11"><div className="mb-3 flex items-center gap-3"><span className="shrink-0 font-mono text-[10px] tracking-[0.09em] text-[#788394]">DELEGATED TO {exchange.tasks.length} {exchange.tasks.length === 1 ? 'AGENT' : 'AGENTS'}</span><div className="h-px w-full bg-[#252a32]" /></div><div className="space-y-2.5">{exchange.tasks.map((task) => <TaskCard key={task.id} task={task} onClick={() => setSelectedTask({ exchangeId: exchange.id, taskId: task.id })} />)}</div></div>
                      <div className="space-y-3 pl-11">{exchange.tasks.filter((task) => task.status === 'completed').map((task) => <div key={task.id} className="border-l border-[#3b4f72] py-0.5 pl-3.5"><div className="flex items-center gap-2"><span className="text-[11px] font-semibold text-[#cbd3e2]">{task.name}</span><span className="flex items-center gap-0.5 font-mono text-[10px] text-[#94b2e9]"><Icon name="check" size={11} />Completed</span></div><p className="mt-1 text-[12px] leading-5 text-[#969faa]">{task.result}</p></div>)}{exchange.tasks.filter((task) => task.status === 'working').slice(0, 1).map((task) => <div key={task.id} className="border-l border-[#364d74] py-0.5 pl-3.5"><div className="text-[11px] font-semibold text-[#cbd3e2]">{task.name}</div><div className="mt-1.5 flex items-center gap-2 font-mono text-[10px] text-[#88a8e9]"><span className="h-[5px] w-[5px] animate-pulse rounded-full bg-[#7da4ff]" />{task.step === 0 ? task.id === 'admin' ? 'Updating components...' : 'Inspecting authentication...' : 'Running tests...'}</div></div>)}</div>
                    </div>
                  ))}
                </div>
              )}
            </main>

            <div className="shrink-0 border-t border-[#1e2227] bg-[#0e1013] px-4 pb-[calc(13px+env(safe-area-inset-bottom))] pt-3">
              <div className="rounded-[17px] border border-[#383d46] bg-[#1d2127] p-2.5 shadow-[0_8px_26px_#0005] focus-within:border-[#6179a9]">
                {attachment && <div className="mb-2 flex w-fit items-center gap-2 rounded-md border border-[#3a4352] bg-[#293140] px-2 py-1 font-mono text-[10px] text-[#b9c7e0]"><Icon name="paperclip" size={12} /><span className="max-w-[180px] truncate">{attachment}</span><button onClick={() => setAttachment(null)} aria-label="Remove attachment"><Icon name="close" size={12} /></button></div>}
                <textarea value={draft} onChange={(event) => setDraft(event.target.value)} onKeyDown={(event) => { if (event.key === 'Enter' && !event.shiftKey) { event.preventDefault(); send() } }} placeholder="Message your development team..." rows={2} className="max-h-32 min-h-[45px] w-full resize-none bg-transparent px-1.5 pt-1.5 text-[13px] leading-5 text-[#f1f2f4] outline-none placeholder:text-[#777f8b]" aria-label="Message your development team" />
                <div className="flex items-end justify-between"><input ref={fileInput} type="file" className="hidden" onChange={(event) => setAttachment(event.target.files?.[0]?.name ?? null)} /><button onClick={() => fileInput.current?.click()} aria-label="Attach a file" title="Attach a file" className="flex h-8 w-8 items-center justify-center rounded-lg text-[#9ba3af] hover:bg-[#2b3038] hover:text-white"><Icon name="plus" size={19} /></button><button onClick={() => send()} disabled={!draft.trim()} aria-label="Send message" className="flex h-8 w-8 items-center justify-center rounded-[9px] bg-[#82a6f6] text-[#101622] transition-colors hover:bg-[#a4bffc] disabled:bg-[#343a46] disabled:text-[#737c8b]"><Icon name="arrow-up" size={18} strokeWidth={2.1} /></button></div>
              </div>
              <div className="mt-2 text-center font-mono text-[9px] tracking-[0.03em] text-[#5f6875]">AGENTS WORK IN ISOLATED GIT WORKTREES</div>
            </div>
          </>
        )}
        {screen === 'chat' && currentTask && <AgentSheet task={currentTask} onClose={() => setSelectedTask(null)} onStop={stopAgent} />}
      </div>
    </div>
  )
}
