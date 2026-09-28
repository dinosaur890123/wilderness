import { Link } from "@inertiajs/react";
import { Coins, Flame, Shield, Tent, Users } from "lucide-react";
import { AdminShell, StatCard } from "@/components/admin/shell";
import { Card, CardContent } from "@/components/wilderness/card";
import { formatLogs, relativeTime } from "@/lib/camp-layout";
import { cn } from "@/lib/utils";

export default function AdminOverview({
	stats,
	log_totals,
	camp_open,
	recent,
	flash_notice,
}: {
	stats: {
		rsvps: number;
		with_access: number;
		admins: number;
		projects: number;
		shipped: number;
		hours: number;
	};
	log_totals: { circulating: number; granted: number; spent: number };
	camp_open: boolean;
	recent: { id: number; name: string; email: string; rsvped_at: string | null }[];
	flash_notice: string | null;
}) {
	return (
		<AdminShell title="Overview" subtitle="Program summary" flashNotice={flash_notice}>
			<div className="flex flex-col gap-6">
				<div
					className={cn(
						"rounded-lg border px-4 py-3 font-semibold",
						camp_open
							? "border-pill-border bg-pill-background text-pill-foreground"
							: "border-border bg-background/40 text-foreground/60",
					)}
				>
					{camp_open ? "Camp is open to all users." : "Camp is closed. Only admins and invited users can enter."}
				</div>

				<div className="grid grid-cols-3 gap-4">
					<StatCard icon={Users} label="RSVPs" value={stats.rsvps} />
					<StatCard icon={Flame} label="Users with camp access" value={stats.with_access} />
					<StatCard icon={Shield} label="Admins" value={stats.admins} />
					<StatCard icon={Tent} label="Projects" value={stats.projects} />
					<StatCard icon={Tent} label="Shipped projects" value={stats.shipped} />
					<StatCard icon={Flame} label="Hours logged" value={stats.hours} />
				</div>

				<div className="grid grid-cols-3 gap-4">
					<StatCard icon={Coins} label="Logs in circulation" value={`🪵 ${formatLogs(log_totals.circulating)}`} />
					<StatCard icon={Coins} label="Granted by admins" value={`🪵 ${formatLogs(log_totals.granted)}`} />
					<StatCard icon={Coins} label="Spent or removed" value={`🪵 ${formatLogs(log_totals.spent)}`} />
				</div>

				<Card>
					<CardContent className="flex flex-col gap-3">
						<h3 className="text-lg font-semibold">Recent RSVPs</h3>
						{recent.length === 0 && <p className="font-serif italic text-foreground/50">No RSVPs yet.</p>}
						{recent.map((person) => (
							<Link
								key={person.id}
								href={`/admin/users/${person.id}`}
								className="flex flex-row items-center justify-between border-b border-border pb-2 last:border-0 last:pb-0 hover:text-primary"
							>
								<div className="flex flex-col">
									<span className="font-semibold">{person.name}</span>
									<span className="font-serif text-sm text-foreground/50">{person.email}</span>
								</div>
								<span className="font-serif text-sm text-foreground/50">{relativeTime(person.rsvped_at)}</span>
							</Link>
						))}
					</CardContent>
				</Card>
			</div>
		</AdminShell>
	);
}