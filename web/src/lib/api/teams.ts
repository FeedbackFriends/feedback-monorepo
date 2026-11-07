import type { components } from "./generated/openapi"
import { requestAPI } from "./client"
import { getAuthClient } from "@/lib/auth"

export type TeamContext = components["schemas"]["TeamContext"]
export type TeamManagement = components["schemas"]["TeamManagement"]
export type TeamInfo = components["schemas"]["TeamInfo"]
export type OrganizationInput = components["schemas"]["CreateOrganizationInput"]
export type TeamInput = components["schemas"]["CreateTeamInput"]

export async function teamRequest<T>(
  path: string,
  method = "GET",
  body?: unknown,
  signal?: AbortSignal
): Promise<T> {
  const token = await getAuthClient().getIdToken()
  const response = await requestAPI(`/api/leader/teams${path}`, {
    language: "da",
    method,
    signal,
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: body === undefined ? undefined : JSON.stringify(body),
    cache: "no-store",
  })
  return response.json() as Promise<T>
}

export type TeamLeadership = components["schemas"]["TeamLeadership"]
export type LeaderInvitationInfo = components["schemas"]["LeaderInvitationInfo"]
