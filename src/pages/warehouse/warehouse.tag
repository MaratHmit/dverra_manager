| import 'pages/warehouse/units/units-list.tag'
| import 'pages/warehouse/units/unit-edit.tag'
| import 'pages/warehouse/warehouses/warehouses-list.tag'
| import 'pages/warehouse/groups/groups-list.tag'

warehouse
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li(each='{ tabs }', class='{ active: name == tab }')
            a(href='#warehouse/{ link }')
                span { title }

    .column
        units-list(if='{ tab == "units" && !edit }')
        unit-edit(if='{ tab == "units" && edit }')
        groups-units-list(if='{ tab == "groups" && !edit }')
        warehouses-list(if='{ tab == "warehouses" && !edit }')

    script(type='text/babel').
        var self = this

        self.edit = false
        self.tab = 'units'

        self.tabs = [
            {title: 'Товары', name: 'units', link: ''},
            {title: 'Группы', name: 'groups', link: 'groups'},
            {title: 'Склады', name: 'warehouses', link: 'warehouses'},
        ]

        var route = riot.route.create()

        route('/warehouse/new', id => {
            self.tab = 'units'
            observable.trigger('unit-new', id)
            self.edit = true
            self.update()
        })

        route('/warehouse/([0-9]+)', id => {
            self.tab = 'units'
            observable.trigger('unit-edit', id)
            self.edit = true
            self.update()
        })

        route('/warehouse/*/([0-9]+)', (tab, id) => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: true, tab: tab})
                observable.trigger(tab + '-edit', id)
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/warehouse/multi..', () => {
            let q = riot.route.query()
            let ids = q.ids.split(',')
            self.tab = 'units'
            observable.trigger('units-multi-edit', ids)
            self.edit = true
            self.update()
        })

        route('/warehouse/clone..', () => {
            let q = riot.route.query()
            let id = q.id
            self.tab = 'units'
            observable.trigger('units-clone', id)
            self.edit = true
            self.update()
        })

        route('/warehouse/categories/multi..', () => {
            let q = riot.route.query()
            let ids = q.ids.split(',')
            self.tab = 'categories'
            observable.trigger('categories-multi-edit', ids)
            self.edit = true
            self.update()
        })

        route('/warehouse', () => {
            self.edit = false
            self.tab = 'units'
            self.update()
        })

        route('/warehouse/*', tab => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: false, tab: tab})
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/warehouse..', () => {
            self.update({edit: true, tab: 'not-found'})
            observable.trigger('not-found')
        })

        self.on('mount', () => {
            riot.route.exec()
        })