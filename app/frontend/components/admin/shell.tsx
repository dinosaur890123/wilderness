import { Link, usePage } from "@inertiajs/react";
import {
	ArrowLeft,
	Coins,
	Flag,
	LayoutDashboard,
	type LucideIcon,
	Package,
	ScrollText,
	Shield,
	Tent,
	Users,
} from "lucide-react";
import { Children } from "react";
import { Card, CardContent } from "@/components/wilderness/card";
import { cn } from "@/lib/utils";

const TABS: { href: string; label: string; icon: LucideIcon }[] = [
	{ href: "/admin", label: "Overview", icon: LayoutDashboard },
	{ href: "/admin/users", label: "Users", icon: Users },
	{ href: "/admin/projects", label: "Projects", icon: Tent },
	{ href: "/admin/shop", label: "Shop", icon: Package },
	{ href: "/admin/audit", label: "Audit", icon: ScrollText },
	{ href: "/admin/flags", label: "Feature flags", icon: Flag },
];

export function AdminShell({
	title,
	subtitle,
	flashNotice,
	children,
}: {
	title: string;
	subtitle: string;
	flashNotice?: string | null;
	children: React.ReactNode;
}) {
	const { url } = usePage();
	const path = url.split("?")[0];

	return (
		<div className="min-h-dvh bg-linear-to-b from-night-blue to-background">
			<div className="max-w-7xl mx-auto px-8 py-10 flex flex-col gap-7">
				<div className="flex flex-row items-end justify-between gap-4">
					<div className="flex flex-col gap-1">
						<h1 className="text-4xl font-bold flex items-center gap-3">
							<Shield className="text-primary" size={32} strokeWidth={2.67} />
							Admin
						</h1>
						<p className="text-foreground/60 font-serif italic">{subtitle}</p>
					</div>
					<Link
						href="/"
						className="flex items-center gap-2 text-foreground/60 hover:text-foreground font-serif italic text-lg transition-colors"
					>
						<ArrowLeft size={20} strokeWidth={3} /> Back to site
					</Link>
				</div>

				<div className="flex flex-row gap-1 border-b border-border">
					{TABS.map((tab) => {
						const active =
							tab.href === "/admin"
								? path === "/admin"
								: path.startsWith(tab.href);
						return (
							<Link
								key={tab.href}
								href={tab.href}
								className={cn(
									"flex items-center gap-2 px-4 py-2.5 -mb-px border-b-2 font-semibold transition-colors",
									active
										? "border-primary text-primary"
										: "border-transparent text-foreground/50 hover:text-foreground",
								)}
							>
								<tab.icon size={18} strokeWidth={2.5} />
								{tab.label}
							</Link>
						);
					})}
				</div>

				{flashNotice && (
					<div className="rounded-lg border border-secondary/40 bg-secondary/10 px-4 py-3 text-secondary font-semibold">
						{flashNotice}
					</div>
				)}

				<div className="flex flex-col gap-2">
					<h2 className="text-2xl font-bold">{title}</h2>
					{children}
				</div>
			</div>
		</div>
	);
}

export function Tag({
	on,
	onLabel,
	offLabel,
}: {
	on: boolean;
	onLabel: string;
	offLabel: string;
}) {
	return (
		<span
			className={cn(
				"inline-flex items-center gap-1 rounded-full border px-2.5 py-1 text-xs font-semibold uppercase tracking-wide transition-colors",
				on
					? "border-pill-border bg-pill-background text-pill-foreground"
					: "border-border bg-background/60 text-foreground/40",
			)}
		>
			{on ? onLabel : offLabel}
		</span>
	);
}

export function StatCard({
	label,
	value,
	icon: Icon,
}: {
	label: string;
	value: React.ReactNode;
	icon?: LucideIcon;
}) {
	return (
		<Card>
			<CardContent className="flex flex-col gap-1 p-5">
				<span className="flex items-center gap-2 font-serif text-sm text-foreground/50">
					{Icon && <Icon size={16} strokeWidth={3} />}
					{label}
				</span>
				<span className="text-3xl font-bold text-primary">{value}</span>
			</CardContent>
		</Card>
	);
}

export function AdminTable({
	headers,
	empty,
	children,
}: {
	headers: string[];
	empty: string;
	children: React.ReactNode;
}) {
	return (
		<div className="overflow-x-auto rounded-lg border border-border">
			<table className="w-full text-left border-collapse">
				<thead>
					<tr className="bg-background/60 text-foreground/60">
						{headers.map((header) => (
							<th
								key={header}
								className="px-4 py-3 font-semibold uppercase tracking-wide text-xs"
							>
								{header}
							</th>
						))}
					</tr>
				</thead>
				<tbody>
					{Children.count(children) === 0 ? (
						<tr>
							<td
								colSpan={headers.length}
								className="px-4 py-8 text-center font-serif italic text-foreground/50"
							>
								{empty}
							</td>
						</tr>
					) : (
						children
					)}
				</tbody>
			</table>
		</div>
	);
}