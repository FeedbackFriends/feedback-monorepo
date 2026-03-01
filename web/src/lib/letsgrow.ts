// Replace the fallback URL with the live Typeform URL, or set it via
// NEXT_PUBLIC_LETSGROW_EARLY_ACCESS_URL for each environment.
export const earlyAccessUrl =
  process.env.NEXT_PUBLIC_LETSGROW_EARLY_ACCESS_URL ??
  "https://form.typeform.com/to/RSs7TZAj"

export const earlyAccessLabel = "Få tidlig adgang"

export const earlyAccessButtonClass =
  "border border-[#27AB85]/20 bg-gradient-to-b from-[#26A783] to-[#28AE88] text-white shadow-[0_16px_40px_-18px_rgba(39,171,133,0.75)] hover:brightness-105"
