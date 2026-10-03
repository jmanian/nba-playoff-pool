module ColorMath
  module_function

  def rgb(hex)
    hex.delete("#").scan(/../).map { |h| h.to_i(16) }
  end

  # WCAG relative luminance, 0.0 (black) to 1.0 (white).
  def luminance(hex)
    r, g, b = rgb(hex).map do |c|
      c /= 255.0
      (c <= 0.03928) ? c / 12.92 : ((c + 0.055) / 1.055)**2.4
    end
    0.2126 * r + 0.7152 * g + 0.0722 * b
  end

  # Euclidean distance in RGB space; a rough but adequate measure of how
  # distinguishable two colors are side by side.
  def distance(hex_a, hex_b)
    rgb(hex_a).zip(rgb(hex_b)).sum { |a, b| (a - b)**2 }**0.5
  end

  # Black or white, whichever has the higher contrast ratio against `hex`.
  def text_color_for(hex)
    (luminance(hex) > 0.179) ? "#000" : "#fff"
  end
end
