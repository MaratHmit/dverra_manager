| import 'components/catalog.tag'

units-list
    .row
        .col-md-2.hidden-xs.hidden-sm
            catalog-tree(object='UnitGroup', label-field='{ "name" }', children-field='{ "childs" }',
                reload='true', descendants='true')
        .col-md-10.col-xs-12.col-sm-12
            catalog(search='true', sortable='true', object='Unit', cols='{ cols }', reload='true', store='units-list',
                filters='{ categoryFilters }', add='{ add }', dblclick='{ edit }', remove='{ remove }',
                handlers='{ handlers }')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='code') { row.code }
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='price')
                        span { (row.price / 1).toLocaleString() } ₽
                    datatable-cell(name='count') { row.count / 1 }
                    datatable-cell(name='reserved',
                        class=' { handlers.getColor(0, row.reserved) } ') { row.reserved / 1 }
                    datatable-cell(name='rest',
                        class=' { handlers.getColor(1, row.count - row.reserved) } ') { row.count - row.reserved }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Unit'

        var getColor = (type, count) => {
            if (type == 0) {
                if (count > 0)
                    return 'bg-warning'
            } else {
                if (count == 0)
                    return 'bg-danger'
            }
            return null
        }

        self.handlers = {
            getColor: getColor
        }

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'code', value: 'Код' },
            {name: 'name', value: 'Наименование' },
            {name: 'price', value: 'Цена' },
            {name: 'count', value: 'Кол-во' },
            {name: 'reserved', value: 'Резерв' },
            {name: 'rest', value: 'Остаток' },
        ]

        self.add = () => {
            localStorage.removeItem("idUnitGroup")
            if (self.selectedCategory)
                localStorage.setItem("idUnitGroup", self.selectedCategory)
            riot.route('/warehouse/new')
        }

        self.edit = e => riot.route(`/warehouse/${e.item.row.id}`)

        self.one('updated', () => {
            self.tags['catalog-tree'].tags.treeview.on('nodeselect', node => {
                self.selectedCategory = node.__selected__ ? node.id : undefined
                let items = self.tags['catalog-tree'].tags.treeview.getSelectedNodes()
                if (items.length > 0) {
                    let value = items.map(i => i.id).join(',')
                    self.categoryFilters = [{field: 'idGroup', sign: 'IN', value}]
                } else {
                    self.categoryFilters = false
                }
                self.update()
                self.tags.catalog.reload()
            })
        })

        observable.on('units-reload', () => {
            localStorage.removeItem("idUnitGroup")
            self.tags.catalog.reload()
        })