geo-zones
    catalog(object='GeoZone', cols='{ cols }', reload='true', handlers='{ handlers }',
        add='{ permission(add, "settings", "0100") }', dblclick='{ permission(edit, "settings", "1000") }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='note') { row.note }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'GeoZone'
        self.handlers = {}

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'note', value: 'Примечание'},
        ]

        self.add = () => riot.route('/settings/geo-zones/new')

        self.edit = e => riot.route(`settings/geo-zones/${e.item.row.id}`)

        observable.on('geo-zones-reload', () => {
            self.tags.catalog.reload()
        })

