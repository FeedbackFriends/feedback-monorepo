import {
  CalendarDays,
  CheckCircle2,
  Clock3,
  LineChart,
  MessageSquareText,
  Repeat2,
  Sparkles,
} from "lucide-react"
import type { LucideIcon } from "lucide-react"

export type FeatureCard = {
  title: string
  description: string
  icon: LucideIcon
}

export type FaqItem = {
  question: string
  answer: string
}

export const appStoreUrl = "https://apps.apple.com/app/id6742420307"

export const calendarPlatforms = [
  {
    name: "Microsoft Teams",
    icon: "/teams_logo.png",
  },
  {
    name: "Microsoft Outlook",
    icon: "/microsoft_outlook.png",
  },
  {
    name: "Google Calendar",
    icon: "/Google_Calendar_icon.png",
  },
  {
    name: "Apple Calendar",
    icon: "/apple_logo.png",
  },
  {
    name: "Zoho Calendar",
    icon: "/zoho_calendar.png",
  },
  {
    name: "Proton Calendar",
    icon: "/proton-calendar.png",
  },
]

export const problemCards: FeatureCard[] = [
  {
    title: "Det samme møde, uge efter uge",
    description:
      "Teammøder, 1:1s og reviews gentager sig, men formatet bliver sjældent justeret systematisk.",
    icon: Repeat2,
  },
  {
    title: "Mange meninger, ingen vane",
    description:
      "Folk ved godt, når et møde er uklart eller fladt. De observationer bliver bare ikke samlet konsekvent.",
    icon: MessageSquareText,
  },
  {
    title: "For meget tid på mavefornemmelse",
    description:
      "Uden et fast signal er det svært at vide, om møderne faktisk bliver mere nyttige eller bare fortsætter af vane.",
    icon: Clock3,
  },
]

export const workflowSteps: FeatureCard[] = [
  {
    title: "Opret mødet som normalt",
    description:
      "I bliver i de værktøjer, I allerede bruger, uanset om det er Google, Apple, Outlook, Zoho, Proton eller Teams.",
    icon: CalendarDays,
  },
  {
    title: "Tilføj feedback@letsgrow.dk som mødedeltager",
    description:
      "Inviter feedback@letsgrow.dk til møder, og vælg en møde template du har lavet på forhånd tilpasset til mødets type.",
    icon: Sparkles,
  },
  {
    title: "Indsaml svar efter mødet helt automatisk",
    description:
      "Efter mødet giver deltagerne feedback i en mobilapp, der er gjort så nem og friktionsfri som muligt.",
    icon: MessageSquareText,
  },
  {
    title: "Se feedbacken og tag handling",
    description:
      "Mødeholderen får inputs fra mødedeltagere, og kan følge med i om mødetilfredsheden bliver bedre eller dårligere over tid.",
    icon: LineChart,
  },
]

export const wedgeReasons: FeatureCard[] = [
  {
    title: "Det samme møde vender tilbage",
    description:
      "Når et møde sker uge efter uge, giver det mening at følge kvaliteten og justere formatet løbende.",
    icon: Repeat2,
  },
  {
    title: "Gentagelser skaber et mønster",
    description:
      "Enkeltstående feedback siger lidt. Gentagne svar gør det synligt, om mødet bliver bedre, står stille eller falder.",
    icon: LineChart,
  },
  {
    title: "Små justeringer bliver målbare",
    description:
      "Faste møder giver team leads og mødeejere et klart sted at forbedre noget konkret uden at starte et stort projekt.",
    icon: CheckCircle2,
  },
]

export const outcomes: FeatureCard[] = [
  {
    title: "Mere klare møder",
    description:
      "Se hurtigere, om agenda, retning og beslutninger føles tydelige for deltagerne.",
    icon: CheckCircle2,
  },
  {
    title: "Bedre energi i rummet",
    description:
      "Følg om møderne opleves som engagerende eller begynder at dræne teamet.",
    icon: Sparkles,
  },
  {
    title: "Højere oplevet nytte",
    description:
      "Mål om tiden i mødet faktisk skaber værdi, eller om formatet skal strammes op.",
    icon: LineChart,
  },
  {
    title: "Svage mødeformater bliver synlige",
    description:
      "Når et fast møde halter, bliver mønsteret tydeligt nok til, at du kan handle på det.",
    icon: Repeat2,
  },
]

export const faqItems: FaqItem[] = [
  {
    question: "Skal vi ændre vores nuværende måde at oprette møder på?",
    answer:
      "Nej. I opretter mødet som normalt og inviterer bare feedback@letsgrow.dk med. Lets Grow lægger sig oven på den arbejdsgang, I allerede bruger.",
  },
  {
    question: "Er det et langt spørgeskema?",
    answer:
      "Nej. Deltagerne får 2-3 korte spørgsmål lige efter mødet, mens oplevelsen stadig er frisk.",
  },
  {
    question: "Skal deltagerne oprette en konto?",
    answer:
      "Nej. Deltagerne skal ikke oprette en konto for at svare. Værdien starter hos mødeejeren, mens feedbacken forbliver let at give.",
  },
  {
    question: "Hvilke typer møder giver det bedst mening til?",
    answer:
      "Det fungerer bedst på møder, der går igen, som teammøder, 1:1s, reviews og andre møder, hvor I gerne vil kunne følge udviklingen over tid.",
  },
  {
    question: "Hvordan fungerer tidlig adgang?",
    answer:
      "Klik på “Få tidlig adgang”, udfyld den korte Typeform, og fortæl lidt om jeres faste møder. Vi følger op med de teams, der matcher launch-profilen bedst.",
  },
]
