require './cron_parser'

RSpec.describe CronParser do
  describe '#expand' do
    let(:parser) { CronParser.new("") }

    test_cases = {
      'seconds' => (0..59),
      'minutes' => (0..59),
      'hours' => (0..23),
      'days of month' => (1..31),
      'months' => (1..12),
      'days of week' => (0..6)
    }

    shared_examples 'expands correctly' do |field, min, max, expected|
      it "expands #{field} correctly" do
        expect(parser.expand(field, min, max, [])).to eq(expected)
      end
    end

    test_cases.each do |label, range|
      context "when expanding wildcard (*) for #{label}" do
        include_examples 'expands correctly', "*", range.first, range.last, range.to_a
      end

      context "when expanding value list for #{label}" do
        include_examples 'expands correctly', "#{range.first(5).join(',')}", range.first, range.last, range.to_a.first(5)
      end

      context "when expanding range for #{label}" do
        include_examples 'expands correctly', "#{range.entries[0]}-#{range.entries[4]}", range.first, range.last, range.to_a.first(5)
      end

      context "when expanding step for #{label}" do
        include_examples 'expands correctly', "*/5", range.first, range.last, range.step(5).to_a
      end

      context "when expanding specific value for #{label}" do
        include_examples 'expands correctly', "#{range.entries[5]}", range.first, range.last, [range.entries[5]]
      end
    end

    context 'when expanding special characters multiple combinations' do
      context 'when expanding list and step in same field' do
        it 'expands correctly' do
          expect(parser.expand("1,13,27-31", 1, 31, [])).to eq([1, 13, 27, 28, 29, 30, 31])
        end
      end

      context 'when expanding range and step in same field' do
        it 'expands correctly' do
          expect(parser.expand("2-10/3", 1, 12, [])).to eq([2, 5, 8, 11])
        end
      end

      # Every hour on the 1st and 15th of the month
      # 0 * 1,15 * * /usr/bin/find

      # and every 5 minutes between 12:00 and 12:30
      # */5 12 1,15 * * /usr/bin/find

      # Every 2 hours and every 10 minutes on Mondays, Wednesdays, and Fridays
      # */10 */2 * * 1,3,5 /usr/bin/find

      # At 5 AM on the 1st, 15th, and last day of every quarter
      # 0 5 1,15,28-31/1 1-12/3 * /usr/bin/find
    end

    context 'when expanding invalid field' do
      context 'when expanding /3' do
        it 'raises an error ' do
          expect { CronParser.new("* * /3 * * foo").display }.to raise_error(ArgumentError, "Non standard! May not work with every cron.")
        end
      end

      context 'when expanding "@"' do
        it 'raises an error ' do
          expect { CronParser.new("* * @ * * foo").display }.to raise_error(ArgumentError, "Invalid field format: '@'. Only numbers, commas, slashes, and hyphens are allowed.")
        end
      end

      context 'when expanding $/3' do
        it 'raises an error ' do
          expect { CronParser.new("* * /3 * * foo").display }.to raise_error(ArgumentError, "Non standard! May not work with every cron.")
        end
      end

      context 'when expanding 3/3' do
        it 'raises an error ' do
          expect { CronParser.new("* * 3/3 * * foo").display }.to raise_error(ArgumentError, "Non standard! May not work with every cron.")
        end
      end

      context 'when expanding 3/3/3' do
        it 'raises an error ' do
          expect { CronParser.new("* * 3/3/3 * * foo").display }.to raise_error(ArgumentError, "Non standard! May not work with every cron.")
        end
      end

      context 'when expanding 300/3' do
        it 'raises an error ' do
          expect { CronParser.new("* * 3/3 * * foo").display }.to raise_error(ArgumentError, "Non standard! May not work with every cron.")
        end
      end
    end
  end

  describe '#parse' do
    it 'parses a full wildcard cron string' do
      parser = CronParser.new("* * * * * /usr/bin/find")
      result = parser.parse
      expect(result["minute"]).to eq((0..59).to_a)
      expect(result["hour"]).to eq((0..23).to_a)
      expect(result["day of month"]).to eq((1..31).to_a)
      expect(result["month"]).to eq((1..12).to_a)
      expect(result["day of week"]).to eq((0..6).to_a)
      expect(result["command"]).to eq("/usr/bin/find")
    end

    it 'parses a cron string with specific values' do
      parser = CronParser.new("5 0 1 1 0 /usr/bin/find")
      result = parser.parse
      expect(result["minute"]).to eq([5])
      expect(result["hour"]).to eq([0])
      expect(result["day of month"]).to eq([1])
      expect(result["month"]).to eq([1])
      expect(result["day of week"]).to eq([0])
      expect(result["command"]).to eq("/usr/bin/find")
    end

    it 'raises an error for an invalid cron string' do
      expect { CronParser.new("5 0 1 1").display }.to raise_error(ArgumentError, "Invalid cron length.")
    end
  end
end
