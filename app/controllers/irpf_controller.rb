class IrpfController < ApplicationController
  def reports
    render json: {
      profit_from_sales_below_20k:,
      swing_trade:,
      day_trade:,
      fiis:,
      end_year_positions:
    }
  end

  def profit_from_sales_below_20k
    result = Trade.find_by_sql ["
      SELECT
        PRINTF('%.2f', SUM(profit)) AS value
      FROM
      (
        SELECT
          STRFTIME('%m', date) month,
          SUM(net_profit) profit,
          SUM(total_amount) sales_amount
        FROM
          trade t
        LEFT JOIN asset a
      ON t.asset_id = a.id
        WHERE
          date BETWEEN ':year-01-01' AND ':year-12-31'
        AND purchase = 0
        AND net_profit > 0
        AND a.asset_type_id = 1
        AND t.trade_type_id = 1
        GROUP BY month
        HAVING sales_amount < 20000
      )
      ", { year: filter_params[:year].to_i }]

    result[0].value
  end

  def day_trade
    Trade.find_by_sql(["
      SELECT
        month,
        stock_profit + etf_profit + loss AS value
      FROM
      (
        SELECT
          STRFTIME('%m', date) month,
        PRINTF(\"%.2f\", SUM(CASE WHEN net_profit > 0 AND a.asset_type_id = 1 THEN
              net_profit
          ELSE
              0
          END)) AS stock_profit,
          PRINTF(\"%.2f\", SUM(CASE WHEN net_profit > 0 AND a.asset_type_id = 3 THEN
              net_profit
          ELSE
              0
          END)) AS etf_profit,
          PRINTF(\"%.2f\", SUM(CASE WHEN net_profit < 0 THEN
              net_profit
          ELSE
              0
          END)) AS loss
        FROM
          trade t
        LEFT JOIN asset a ON t.asset_id = a.id
        WHERE
          date BETWEEN ':year-01-01' AND ':year-12-31'
        AND t.trade_type_id = 2
          AND purchase = 0
          AND a.asset_type_id IN (1, 3)
          GROUP BY month
      )
      WHERE CAST(value AS decimal) <> 0
      ", { year: filter_params[:year].to_i }]).map { |i| i.attributes.except('id') }
  end

  def swing_trade
    Trade.find_by_sql(["
      SELECT
        month,
        CASE WHEN CAST(stock_sales AS decimal) > 20000 THEN
          stock_profit + etf_profit + loss
        ELSE
          etf_profit + loss
        END Value
        FROM
        (
          SELECT
            STRFTIME('%m', date) month,
          PRINTF(\"%.2f\", SUM(CASE WHEN a.asset_type_id = 1 THEN
            total_amount
          ELSE
            0
          END)) AS stock_sales,
          PRINTF(\"%.2f\", SUM(CASE WHEN net_profit > 0 AND a.asset_type_id = 1 THEN
                net_profit
            ELSE
                0
            END)) AS stock_profit,
            PRINTF(\"%.2f\", SUM(CASE WHEN net_profit > 0 AND a.asset_type_id = 3 THEN
                net_profit
            ELSE
                0
            END)) AS etf_profit,
            PRINTF(\"%.2f\", SUM(CASE WHEN net_profit < 0 THEN
                net_profit
            ELSE
                0
            END)) AS loss
          FROM
            trade t
          LEFT JOIN asset a ON t.asset_id = a.id
          WHERE
            date BETWEEN ':year-01-01' AND ':year-12-31'
          AND t.trade_type_id = 1
            AND purchase = 0
            AND a.asset_type_id IN (1, 3)
            GROUP BY month
        )
        WHERE CAST(Value AS decimal) <> 0
    ", { year: filter_params[:year].to_i }]).map { |i| i.attributes.except('id') }
  end

  def fiis
    Trade.select('STRFTIME("%m", date) month,
                 SUM(net_profit) AS value')
         .where('date BETWEEN ? AND ?
                 AND trade_type_id = 3
                 AND purchase = 0',
                filter_params[:year] + '-01-01',
                filter_params[:year] + '-12-31')
         .group('month').map { |i| i.attributes.except('id') }
  end

  def end_year_positions
    EndYearPosition.select('asset.code,
                            end_year_position.position,
                            ROUND(end_year_position.average_price, 2) AS average_price,
                            ROUND(end_year_position.average_price * end_year_position.position, 2) AS total_cost')
                   .joins(:asset)
                   .where(year: filter_params[:year])
                   .order('asset.code').map { |i| i.attributes.except('id') }
  end

  def filter_params
    params.permit(:year)
  end
end
