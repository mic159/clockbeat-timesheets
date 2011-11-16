# I can't seem to work out how to remove things from the body before they load
# So we need to replace the functions defined by popupcalendarsub that are called
window.location = """
    javascript: function checkLogo(){}; function buildPage(){}; function biggercomment(){};
"""

window.onload = ->
document.onclick = ->

# Some dom manipulation before we begin
$("head, style").empty()
body = $ "body"
body.attr onload:""
$("script:last", body).addClass("activities_javascript")

# Finally! Start!
styler.setupOnPop()
styler.start body
