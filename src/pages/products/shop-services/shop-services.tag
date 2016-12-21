| import 'components/catalog.tag'

shop-services
    h4 Услуги магазина
    catalog(object='ShopService', cols='{ cols }', search='true', reorder='true', handlers='{ handlers }', reload='true',
        store='shop-services',
        add='{ add }', remove='{ remove }', dblclick='{ edit }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='price')
                span { (row.price / 1).toLocaleString() } ₽
            datatable-cell(name='sort') { row.sort }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Label'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'price', value: 'Цена'},
            {name: 'sort', value: 'Порядок'},
        ]

        self.add = () => riot.route('/products/shop-services/new')

        self.edit = e => riot.route(`products/shop-services/${e.item.row.id}`)

        observable.on('shop-services-reload', () => self.tags.catalog.reload())
