| import 'pages/requests/requests-list.tag'
| import 'pages/requests/request-edit.tag'

requests
    requests-list(if='{ tab == "requests" && !edit }')
    request-edit(if='{ tab == "requests" && edit }')

    script(type='text/babel').
        var self = this

        self.edit = false
        self.notFound = false

        var route = riot.route.create()

        route('/requests', () => {
            self.edit = false
            self.tab = 'requests'
            self.notFound = false
            self.update()
        })

        route('/requests/([0-9]+)', id => {
            observable.trigger('request-edit', id)
            self.edit = true
            self.notFound = false
            self.tab = 'requests'
            self.update()
        })

        route('/requests/*', tab => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: false, tab: tab})
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/requests..', () => {
            self.notFound = true
            self.tab = 'requests'
            self.update()
            observable.trigger('not-found')
        })

        self.on('mount', function () {
            riot.route.exec()
        })
