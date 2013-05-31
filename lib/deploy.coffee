request = require 'request'
jsdom = require 'jsdom'
fs = require 'fs'
async = require 'async'

class Deploy
	constructor: (@username, @password, @server) ->
		@server ?= 'rally1.rallydev.com'

	createNewPage: (cpoid, name, content, tab, callback) ->
    dashboardOid = null
    panelOid = null

		#callback ?= () ->
		async.waterfall(
      [
        @_login
      ,
        (res, b, cb) ->
          mtab = tab or 'myhome'
          options =
            url: "https://#{@server}/slm/wt/edit/create.sp"
            method: 'POST'
            followAllRedirects: true
            form:
              name: name
              #html: content
              type: 'DASHBOARD'
              timeboxFilter: 'none'
              pid: mtab
              editorMode: 'create'
              cpoid: cpoid
              version: 0

          request(options, cb)
      ,
        (results, body, cb) ->
          jsdom.env(body, cb)
      ,
        (window, cb) ->
          oidElt = window.document.getElementsByName 'oid'
          dashboardOid = oidElt?[0]?.value

          options = {
            url: "https://#{@server}/slm/panel/getCatalogPanels.sp?cpoid=#{cpoid}&ignorePanelDefOids&gesture=getcatalogpaneldefs&_slug=/custom/#{dashboardOid}",
            method: 'GET'
          }

          request(options, cb)
      ,
        (results, body, cb) ->
          panels = JSON.parse body

          for p in panels
            ptoid = p.oid if p.title is "Custom HTML"

          options =
            url: "https://#{@server}/slm/dashboard/addpanel.sp?cpoid=#{cpoid}&_slug=/custom/#{dashboardOid}"
            method: 'POST'
            followAllRedirects: true
            form:
              panelDefinitionOid: ptoid
              col: 0
              index: 0
              dashboardName: "#{tab}#{dashboardOid}"
              gestrure: 'addpanel'
            #jar: @cookieJar

          request(options, cb)
      ,
        (results, body, cb) ->
          #console.log "Error", error

          #fs.writeFileSync "#{process.cwd()}/_test.html", body
          #console.log "Results", results
          #console.log "Body", body

          panelOid = JSON.parse(body).oid

          options =
            url: "https://#{@server}/slm/dashboard/changepanelsettings.sp?cpoid=#{cpoid}&_slug=/custom/#{dashboardOid}"
            method: 'POST'
            followAllRedirects: true
            form:
              oid: panelOid
              dashboardName: "#{tab}#{dashboardOid}"
              settings: JSON.stringify {title: name, content: content}
              gestrure: 'changepanelsettings'
            #jar: @cookieJar

          request(options, cb)
      ,
        (results, body, cb) ->
          options =
            url: "https://#{@server}/slm/dashboardSwitchLayout.sp?cpoid=#{cpoid}&layout=SINGLE&dashboardName=#{tab}#{dashboardOid}&_slug=/custom/#{dashboardOid}"
            method: 'GET'

          request(options, cb)
      ,
        (results, body, cb) ->
      ], (err) ->
        callback(dashboardOid, panelOid)
      )

	updatePage: (doid, poid, cpoid, name, tab, content, callback) ->
		#callback ?= () ->

		@_login (err, res, b) ->
      mtab = tab or 'myhome'

      options =
        url: "https://#{@server}/slm/dashboard/changepanelsettings.sp?cpoid=#{cpoid}&_slug=/custom/#{doid}"
        method: 'POST'
        followAllRedirects: true
        form:
          oid: poid
          dashboardName: "#{tab}#{doid}"
          settings: JSON.stringify {title: name, content: content}
          gestrure: 'changepanelsettings'

      request options, (error, results, body) ->
        callback()

	_login: (callback) ->
		#callback ?= () ->

		options =
			url: "https://#{@server}/slm/platform/j_platform_security_check.op"
			method: 'POST'
			followAllRedirects: true
			form:
				j_username: @username
				j_password: @password

		request options, (err, res, body) ->
      callback(err, res, body)

exports.Deploy = Deploy
