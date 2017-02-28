| import 'pages/requests/requests-list.tag'
| import 'pages/requests/request-edit.tag'
| import 'pages/requests/measurements-list.tag'
| import 'pages/requests/measurement-edit.tag'

requests
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li(each='{ tabs }', class='{ active: name == tab }')
            a(href='#requests/{ link }')
                span { title }

    .column
        requests-list(if='{ tab == "requests" && !edit }')
        request-edit(if='{ tab == "requests" && edit }')
        measurements-list(if='{ tab == "measurements" && !edit }')
        measurement-edit(if='{ tab == "measurements" && edit }')

    script(type='text/babel').
        var self = this

        self.edit = false
        self.notFound = false

        self.tabs = [
            {title: 'Заявки', name: 'requests', link: ''},
            {title: 'Замеры', name: 'measurements', link: 'measurements'},
        ]


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

        route('/requests/measurements/([0-9]+)', (tab, id) => {
            self.edit = true
            self.tab = 'measurements'
            self.update()
            observable.trigger('measurement-edit', id)
        })

        route('/requests/measurements/new', () => {
            self.edit = true
            self.tab = 'measurements'
            self.update()
            observable.trigger('measurement-new')
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


