import type { ReactNode } from "react";

import { cn } from "@/lib/utils";

type GoogleMapsLinkProps = {
  /** String in the form "lat,lng" */
  query: string;
  children: ReactNode;
  className?: string;
  title?: string;
};

const normalizeLatLngQuery = (query: string) => {
  const parts = query.split(",").map((p) => p.trim()).filter(Boolean);
  if (parts.length >= 2) return `${parts[0]},${parts[1]}`;
  return query.trim();
};

const GoogleMapsLink = ({ query, children, className, title }: GoogleMapsLinkProps) => {
  const normalized = normalizeLatLngQuery(query);

  return (
    <a
      href={`https://www.google.com/maps/search/?api=1&query=${normalized}`}
      target="_blank"
      rel="noopener noreferrer"
      className={cn(className)}
      title={title}
    >
      {children}
    </a>
  );
};

export default GoogleMapsLink;
