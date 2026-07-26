"use client";

import { useEffect, useState } from "react";
import type { ApiResponse, Delegation } from "@delego/types";
import { api } from "../lib/api";

/**
 * Fetch the current user's delegations from the Delego API.
 */
function isDelegationArray(data: unknown): data is Delegation[] {
  if (!Array.isArray(data)) return false;
  return data.every(
    (item) =>
      typeof item === "object" &&
      item !== null &&
      "id" in item &&
      "userId" in item &&
      "agentId" in item &&
      "status" in item
  );
}

/** Fetch user delegations — TODO: Add SWR or React Query */
export function useDelegations() {
  const [delegations, setDelegations] = useState<Delegation[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const controller = new AbortController();

    api
      .getDelegations({ signal: controller.signal })
      .then((res: ApiResponse<Delegation[]>) => {
        if (res.error) {
          setError(res.error.message);
        } else if (!isDelegationArray(res.data)) {
          setError("Invalid response format");
        } else {
          setDelegations(res.data);
        }
      })
      .catch((err: unknown) => {
        if (err instanceof DOMException && err.name === "AbortError") {
          return;
        }
        setError("Failed to fetch delegations");
      })
      .finally(() => {
        if (!controller.signal.aborted) {
          setLoading(false);
        }
      });

    return () => {
      controller.abort();
    };
  }, []);

  return { delegations, loading, error };
}
