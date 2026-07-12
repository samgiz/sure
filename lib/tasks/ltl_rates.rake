namespace :ltl do
  desc "Seed the fixed LTL<->EUR peg (1 EUR = 3.45280 LTL) as ExchangeRate rows"
  task seed_rates: :environment do
    peg     = BigDecimal("3.4528")      # LTL per 1 EUR
    ltl_eur = BigDecimal("1") / peg     # ~0.2896199... EUR per 1 LTL
    range   = Date.new(2002, 2, 2)..Date.new(2015, 1, 1) # full EUR-peg era

    range.each do |d|
      ExchangeRate.find_or_create_by!(from_currency: "LTL", to_currency: "EUR", date: d) { |r| r.rate = ltl_eur }
      ExchangeRate.find_or_create_by!(from_currency: "EUR", to_currency: "LTL", date: d) { |r| r.rate = peg }
    end

    puts "Seeded LTL<->EUR peg for #{range.count} days."
  end
end
