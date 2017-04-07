accessories-list
    catalog(object='Accessory', cols='{ cols }', search='true', sortable='true', handlers='{ handlers }', reload='true',
            store='accessories-list', add='{ permission(add, "products", "0100") }',
            remove='{ permission(remove, "products", "0001") }',
            dblclick='{ permission(open, "products", "1000") }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='code') { row.code }
            datatable-cell(name='type') { handlers.typeValues[row.type] }
            datatable-cell(name='discount') { row.discount }
            datatable-cell(name='minSumOrder') { row.minSumOrder }
            datatable-cell(name='status') { row.status == 'Y' ? 'Да' : 'Нет' }
            datatable-cell(name='countUsed') { row.countUsed }
            datatable-cell(name='onlyRegistered') { row.onlyRegistered == 'Y' ? 'Да' : 'Нет' }
            datatable-cell(name='expireDate') { row.expireDate }

    script(type='text/babel').

        var self = this

        self.mixin('remove')
        self.mixin('permissions')
        self.mixin('change')
        self.collection = 'Coupon'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
        ]

        self.add = e => riot.route(`products/accessories/new`)