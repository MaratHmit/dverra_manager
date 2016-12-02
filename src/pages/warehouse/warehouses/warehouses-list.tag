| import 'components/catalog.tag'

warehouses-list
    catalog(search='true', sortable='true', object='Warehouse', cols='{ cols }', reload='true', store='warehouses-list',
        add='{ add }', remove='{ remove }', dblclick='{ edit }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='address') { row.address }
            datatable-cell(name='phone') { row.phone }
            datatable-cell(name='note') { row.note }

    style(scoped).
        .table td {
            vertical-align: middle !important;
        }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Warehouse'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование' },
            {name: 'address', value: 'Адрес' },
            {name: 'phone', value: 'Телефон' },
            {name: 'note', value: 'Примечание' },
        ]

        self.add = () => riot.route(`/warehouse/warehouses/new`)
        self.edit = e => riot.route(`/warehouse/warehouses/${e.item.row.id}`)

        observable.on('warehouses-reload', () => {
            self.tags.catalog.reload()
        })