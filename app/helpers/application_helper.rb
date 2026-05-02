module ApplicationHelper
  # Renders both light- and dark-mode variants of a team's logo; CSS shows
  # the one matching the active `data-bs-theme` on <html>.
  # Returns nil if the team has no external_id (no logo available).
  def team_logo_tag(team, size: 24, **options)
    return nil unless team&.external_id

    classes = ["team-logo", options.delete(:class)].compact.join(" ")
    alt = options.delete(:alt) || "#{team.full_name} logo"

    safe_join([
      image_tag(team.logo_url(theme: :light),
        class: "#{classes} team-logo--light",
        alt: alt, width: size, height: size, loading: "lazy", **options),
      image_tag(team.logo_url(theme: :dark),
        class: "#{classes} team-logo--dark",
        alt: alt, width: size, height: size, loading: "lazy", **options)
    ])
  end
end
