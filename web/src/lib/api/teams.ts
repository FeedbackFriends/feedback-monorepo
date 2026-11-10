import type { components, operations } from "./generated/openapi"
import { requestAPI } from "./client"
import { getAuthClient } from "@/lib/auth"

export type TeamContext = components["schemas"]["TeamContext"]
export type TeamManagement = components["schemas"]["TeamManagement"]
export type TeamInfo = components["schemas"]["TeamInfo"]
export type OrganizationInput = components["schemas"]["CreateOrganizationInput"]
export type TeamInput = components["schemas"]["CreateTeamInput"]
export type TeamLeadership = components["schemas"]["TeamLeadership"]
export type LeaderInvitationInfo = components["schemas"]["LeaderInvitationInfo"]
export type LeaderInvitationInput = components["schemas"]["InviteLeaderInput"]

type TeamOperation =
  | "suggestionInbox"
  | "publishSuggestionDecision"
  | "reportedSuggestions"
  | "moderateSuggestion"
  | "pendingLeaderInvitations"
  | "context"
  | "management"
  | "leadership"
  | "createOrganization"
  | "createTeam"
  | "approve"
  | "reject"
  | "remove"
  | "rotate"
  | "inviteLeader"
  | "removeLeader"
  | "revokeLeaderInvite"
  | "leaderInvitation"
  | "acceptLeadership"
type Result<K extends TeamOperation> =
  operations[K]["responses"][200]["content"]["application/json"]

// Only named operations below are public. Screens cannot choose an arbitrary response type.
async function request<K extends TeamOperation>(
  path: string,
  method: "GET" | "POST" | "DELETE",
  signal?: AbortSignal,
  body?: unknown,
): Promise<Result<K>> {
  signal?.throwIfAborted()
  const token = await getAuthClient().getIdToken()
  signal?.throwIfAborted()
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
  return response.json() as Promise<Result<K>>
}

const segment = encodeURIComponent
export const getTeamContext = (signal?: AbortSignal) =>
  request<"context">("/context", "GET", signal)
export const getTeam = (teamId: string, signal?: AbortSignal) =>
  request<"management">(`/${segment(teamId)}`, "GET", signal)
export const getTeamLeaders = (teamId: string, signal?: AbortSignal) =>
  request<"leadership">(`/${segment(teamId)}/leaders`, "GET", signal)
export const createOrganization = (
  input: OrganizationInput,
  signal?: AbortSignal,
) => request<"createOrganization">("/organizations", "POST", signal, input)
export const createTeam = (
  organizationId: string,
  input: TeamInput,
  signal?: AbortSignal,
) =>
  request<"createTeam">(
    `/organizations/${segment(organizationId)}`,
    "POST",
    signal,
    input,
  )
export const approveTeamRequest = (
  teamId: string,
  requestId: string,
  signal?: AbortSignal,
) =>
  request<"approve">(
    `/${segment(teamId)}/requests/${segment(requestId)}/approve`,
    "POST",
    signal,
  )
export const rejectTeamRequest = (
  teamId: string,
  requestId: string,
  signal?: AbortSignal,
) =>
  request<"reject">(
    `/${segment(teamId)}/requests/${segment(requestId)}/reject`,
    "POST",
    signal,
  )
export const removeTeamMember = (
  teamId: string,
  accountId: string,
  signal?: AbortSignal,
) =>
  request<"remove">(
    `/${segment(teamId)}/members/${segment(accountId)}`,
    "DELETE",
    signal,
  )
export const rotateTeamInvite = (teamId: string, signal?: AbortSignal) =>
  request<"rotate">(`/${segment(teamId)}/invite`, "POST", signal)
export const inviteTeamLeader = (
  teamId: string,
  input: LeaderInvitationInput,
  signal?: AbortSignal,
) =>
  request<"inviteLeader">(
    `/${segment(teamId)}/leaders/invitations`,
    "POST",
    signal,
    input,
  )
export const removeTeamLeader = (
  teamId: string,
  accountId: string,
  signal?: AbortSignal,
) =>
  request<"removeLeader">(
    `/${segment(teamId)}/leaders/${segment(accountId)}`,
    "DELETE",
    signal,
  )
export const revokeLeaderInvitation = (
  teamId: string,
  invitationId: string,
  signal?: AbortSignal,
) =>
  request<"revokeLeaderInvite">(
    `/${segment(teamId)}/leaders/invitations/${segment(invitationId)}`,
    "DELETE",
    signal,
  )
export const getLeaderInvitation = (code: string, signal?: AbortSignal) =>
  request<"leaderInvitation">(
    `/leader-invitations/${segment(code)}`,
    "GET",
    signal,
  )
export const acceptLeaderInvitation = (
  input: components["schemas"]["AcceptLeaderInput"],
  signal?: AbortSignal,
) =>
  request<"acceptLeadership">(
    "/leader-invitations/accept",
    "POST",
    signal,
    input,
  )

export const getPendingLeaderInvitations = (signal?: AbortSignal) => request<"pendingLeaderInvitations">("/leader-invitations", "GET", signal)

export const getReportedSuggestions = (teamId: string, signal?: AbortSignal) =>
  request<"reportedSuggestions">(`/${segment(teamId)}/suggestions/reports`, "GET", signal)
export const moderateTeamSuggestion = (teamId: string, suggestionId: string, remove: boolean, signal?: AbortSignal) =>
  request<"moderateSuggestion">(`/${segment(teamId)}/suggestions/${segment(suggestionId)}/moderation`, "POST", signal, { remove })

export type SuggestionInbox = components["schemas"]["SuggestionInbox"]
export type PublishSuggestionDecisionInput = components["schemas"]["PublishSuggestionDecisionInput"]
export const getSuggestionInbox = (teamId: string, signal?: AbortSignal) =>
  request<"suggestionInbox">(`/${segment(teamId)}/suggestions/inbox`, "GET", signal)
export const publishSuggestionDecision = (teamId: string, suggestionId: string, input: PublishSuggestionDecisionInput, signal?: AbortSignal) =>
  request<"publishSuggestionDecision">(`/${segment(teamId)}/suggestions/${segment(suggestionId)}/decisions`, "POST", signal, input)
