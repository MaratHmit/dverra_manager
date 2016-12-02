services
    catalog(object='Service', cols='{ cols }', reload='true', handlers='{ handlers }',
    dblclick='{ serviceOpen }')
        #{'yield'}(to='body')
            datatable-cell(name='code') { row.code }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='note') { row.note }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.collection = 'Service'
        self.handlers = {}

        self.cols = [
            {name: 'code', value: 'Код'},
            {name: 'name', value: 'Наименование'},
            {name: 'note', value: 'Примечание'},
        ]

        self.serviceOpen = e => riot.route(`settings/services/${e.item.row.id}`)

        observable.on('services-reload', () => {
            self.tags.catalog.reload()
        })
