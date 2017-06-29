#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require materialize-sprockets
#= require archives

$(document).on 'turbolinks:load ', ->
  Materialize.updateTextFields()
  Waves.displayEffect()
  $('.button-collapse').sideNav()

  $('.datepicker').pickadate
    monthsFull:  ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
    monthsShort: ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
    weekdaysFull: ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"],
    weekdaysShort:  ["日", "月", "火", "水", "木", "金", "土"],
    weekdaysLetter: ["日", "月", "火", "水", "木", "金", "土"],
    labelMonthNext: "翌月",
    labelMonthPrev: "前月",
    labelMonthSelect: "月を選択",
    labelYearSelect: "年を選択",
    today: "今日",
    clear: "クリア",
    close: "閉じる",
    format: "yyyy/mm/dd",

  $('select.materialize-select').material_select();

  html = $('#flash-dialog').html()
  if html
    $toast = $(html);
    Materialize.toast($toast, 10000);

  #
  # コントローラ.アクション毎のメソッドを呼び出す
  #
  $.reki ?= {}
  $.reki.classes ?= {}
  window.activeController = null
  $body = $('body')
  if $body.data('controller')
    controller = $body.data('controller').replace(/\//g, '_')
    template = $body.data('template')

    if $.reki.classes && $.reki.classes[controller]
      klass = $.reki.classes[controller]

      if klass != undefined
        window.activeController = new klass
        if $.isFunction(activeController[template])
          window.activeController[template]()


  $fixed_content = $('.fixed-height')
  if $fixed_content.length > 0
    height1 = $fixed_content.outerHeight()
    height2 = $(document).height()
    height3 = $(window).height()

    # fixed-height要素以外の高さ合計
    height4 = height2 - height1

    $fixed_content.height(height3 - height4)
    $fixed_content.css("visibility", "visible")
    $("body").css("overflow-y", "hidden")
