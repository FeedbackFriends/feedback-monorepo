import type { ComponentProps } from "react"
import PrimaryButton from "@/components/ui/PrimaryButton"
import type { EarlyAccessButtonProps } from "@/components/ui/EarlyAccessButton"

type GoogleLoginButtonProps = Pick<EarlyAccessButtonProps, "className" | "size"> &
  Pick<ComponentProps<typeof PrimaryButton>, "disabled" | "onClick">

function GoogleLoginButton({
  className,
  disabled,
  onClick,
  size,
}: GoogleLoginButtonProps) {
  return (
    <PrimaryButton
      className={className}
      disabled={disabled}
      onClick={onClick}
      size={size}
      type="button"
    >
      Fortsæt med Google
    </PrimaryButton>
  )
}

export default GoogleLoginButton
