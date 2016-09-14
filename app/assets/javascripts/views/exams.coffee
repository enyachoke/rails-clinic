# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class Exam

  placeholder_data_attributes:
    controller: "exams"
    action: "index"

  remoteContent: null

  #Diag
  diagTable: null
  diags_div_id: "diags_div"
  new_diag_btn_id: "new_diag"

  #Drug
  drugTable: null
  drug_ins_div_id: "drug_ins_div"
  drug_usages_div_id: "drug_usages_div"
  new_drug_btn_id: "new_drug"

  initializePage: () ->
    view.panelUtil.initToggleCollapseSwapIcon $("div#customerShow")
    view.panelUtil.initToggleCollapseSwapIcon $("div[id*='exam']")

    delete @diagTable
    @diagTable = new view.ExamDiagDataTable(@new_diag_btn_id, view.util)
    @diagTable.diags_div_id = @diags_div_id
    @diagTable.initializeTable()

    delete @drugTable
    @drugTable = new view.ExamDrugDataTable(@new_drug_btn_id, view.util)
    @drugTable.drug_ins_div_id = @drug_ins_div_id
    @drugTable.drug_usages_div_id = @drug_usages_div_id
    @drugTable.initializeTable()

  fetchAjaxContent: ()->
    if not @remoteContent?
      @remoteContent = new view.RemoteContent @placeholder_data_attributes

    @remoteContent.fetchAjaxContent()

#  submitDiagTable: () ->
#    console.log @diagTable.$('input, select').serialize();

#  lastRow: () ->
#    @diagTable.row(@rowCount - 1)

#  rowCount: () ->
#    @diagTable.rows().count()

view.exam = new Exam

#drug_drug_ins_path_pattern = (drug_id)->
#  "/drugs/#{drug_id}/drug_ins"

#initializePage = ->
  # new exam button click ajax error
  #$('a[href*="new_patient_diag"]').on 'ajax:error', (event, xhr, status, error)-> gShowErrorModal error

  # append anchor to form action url
  #$('form').each (index, form) ->
  #  f = $(form)
  #  anchor = f.data('anchor')
  #  if anchor?
  #    action = f.attr 'action'
  #    f.attr 'action', "#{action}#" + anchor

  # drug id
  #$('select#drug_in_drug_id').on "change", ()->
  #  $('a#link_drug_drug_ins_path').attr("href", drug_drug_ins_path_pattern(this.value) )

#$(document).on('turbolinks:load', initializePage)

