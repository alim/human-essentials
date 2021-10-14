# Exports a generic report to csv
# expects a reporter with a report method returns a hash with keys corresponding to columns and values corresponding to the reported value
# It should also have a columns_for_csv method to determine the order of the columns
module Exports
  class ExportReportCSVService
    def initialize(reporters:)
      @reporters = reporters
    end

    def generate_csv
      csv_data = generate_csv_data

      ::CSV.generate(headers: true) do |csv|
        csv_data.each { |row| csv << row }
      end
    end

    def generate_csv_data
      headers = []
      data = []

      csv_data = []

      @reporters.each do |reporter|
        headers.concat(headers(reporter))
        data.concat(build_row_data(reporter))
      end

      csv_data << headers
      csv_data << data

      csv_data
    end

    private

    attr_reader :report

    def headers(reporter)
      reporter.columns_for_csv.map(&:to_s).map(&:humanize)
    end

    # Returns a Hash of keys to indexes so that obtaining the index
    # doesn't require a linear scan.
    def headers_with_indexes
      @headers_with_indexes ||= headers.each_with_index.to_h
    end

    def build_row_data(reporter)
      reporter.columns_for_csv.map { |column| reporter.report[column] }
    end
  end
end
