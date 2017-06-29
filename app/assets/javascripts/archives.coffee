class ArchivesController

  index: =>
    $("#check_all").change (e)=>
      if $("#check_all").prop('checked')
        $("input[name^=ids]").prop('checked', true)
      else
        $("input[name^=ids]").prop('checked', false)

  new:  =>
    @setup_form()

  edit: =>
    @setup_form()

  setup_form: =>

    $("#btn-extract-tag").click (e)->
      desc = $("#archive_description").val()
      $.ajax(
        url: "/archives/extract_tag"
        data: "keyword=#{desc}"
        dataType: "script"
      )

$.reki ?= {}
$.reki.classes ?= {}
$.reki.classes.archives = ArchivesController
