import {Link } from "@inertiajs/react";
import {AdminShell, AdminTable, Tag} from "@/components/admin/shell";
import {relativeTime} from "@/lib/camp-layout";
type AuditEvent = {
    id: number;
	action: string;
	actor: string;
	actor_id: number | null;
	target: string | null;
	target_id: number | null;
	subject: string | null;
	metadata: Record<string, string | number | boolean | null>;
	created_at: string;
}

const ACTION_LABELS: Record<string, string> = {
    "user.admin_granted": "Granted admin access",
	"user.admin_revoked": "Revoked admin access",
	"logs.granted": "Granted logs",
	"logs.removed": "Removed logs",
	"logs.awarded": "Awarded logs for a ship",
	"project.created": "Created a project",
	"project.updated": "Updated a project",
	"project.shipped": "Shipped a project",
	"project.approved": "Approved a ship",
	"shop_item.created": "Added a shop item",
	"shop_item.updated": "Updated a shop item",
	"shop_item.deleted": "Deleted a shop item",
	"flag.enabled": "Enabled a feature flag",
	"flag.disabled": "Disabled a feature flag",
	"hackatime.connected": "Connected Hackatime",
	"hackatime.disconnected": "Disconnected Hackatime",
};

const CATEGORY_LABELS: Record<string, string> = {
	admin: "Admin",
	logs: "Logs",
	projects: "Projects",
	shop: "Shop",
	users: "Users",
};
export default function AdminAudit({
	events,
	category,
	categories,
	flash_notice,
}: {
	events: AuditEvent[];
	category: string;
	categories: string[];
	flash_notice: string | null;
}) {
	return (
		<AdminShell title="Audit" subtitle="The 200 most recent actions" flashNotice={flash_notice}>
			<div className="flex flex-col gap-4">
				<div className="flex flex-row flex-wrap gap-2">
					{["", ...categories].map((option) => {
						const label = option ? CATEGORY_LABELS[option] : "All";
						return (
							<Link
								key={option}
								href={option ? `/admin/audit?category=${option}` : "/admin/audit"}
								preserveScroll
							>
								<Tag on={category === option} onLabel={label} offLabel={label} />
							</Link>
						);
					})}
				</div>
				<AdminTable headers={["When", "Actor", "Action", "Target", "Details"]} empty="Nothing recorded yet.">
					{events.map((event) => (
						<tr key={event.id} className="border-t border-border align-top">
							<td className="whitespace-nowrap px-4 py-3 font-serif text-sm text-foreground/60">
								{relativeTime(event.created_at)}
							</td>
							<td className="px-4 py-3 text-sm">
								{event.actor_id ? (
									<Link href={`/admin/users/${event.actor_id}`} className="font-semibold hover:underline">
										{event.actor}
									</Link>
								) : (
									<span className="text-foreground/40">{event.actor}</span>
								)}
							</td>
							<td className="px-4 py-3 text-sm font-semibold">{ACTION_LABELS[event.action] ?? event.action}</td>
							<td className="px-4 py-3 text-sm">
								{event.target_id ? (
									<Link href={`/admin/users/${event.target_id}`} className="hover:underline">
										{event.target}
									</Link>
								): (
									<span className="text-foreground/30">—</span>
								)}
								{event.subject && event.subject !== event.target && (
									<div className="font-serif text-sm text-foreground/50">{event.subject}</div>
								)}
								</td>
								<td className="px-4 py-3">
								<Details metadata={event.metadata}/>
							</td>
						</tr>
						))}
				</AdminTable>
			</div>
		</AdminShell>
	);
}

function Details({metadata}: {metadata: Record<string, string | number | boolean | null>}) {
	const entries = Object.entries(metadata);
	if (entries.length === 0) return <span className="text-foreground/30">—</span>;

	return (
		<div className="flex flex-col gap-0.5 text-sm">
			{entries.map(([key, value]) => (
				<div key={key} className="flex gap-2">
					<span className="text-foreground/40">{key.replace("_", " ")}</span>
					<span className="text-foreground/80">{String(value)}</span>
				</div>
			))}
		</div>
	);
}