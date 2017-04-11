units-list-select-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Товары
        #{'yield'}(to="body")
            .row
                .col-md-3.hidden-xs.hidden-sm
                    catalog-tree(object='UnitGroup', label-field='{ "name" }', children-field='{ "childs" }',
                        descendants='true')
                .col-md-9.col-xs-12.col-sm-12
                    catalog(object='Unit', cols='{ parent.cols }', search='true', sortable='true',
                        dblclick='{ parent.opts.submit.bind(this) }',
                        disable-limit='true', disable-col-select='true', filters='{ categoryFilters }')
                        #{'yield'}(to='body')
                            datatable-cell(name='id') { row.id }
                            datatable-cell(name='code') { row.code }
                            datatable-cell(name='name') { row.name }
                            datatable-cell(name='priceRetail')
                                span { (row.priceRetail / 1).toLocaleString() } ₽
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'code', value: 'Код'},
            {name: 'name', value: 'Наименование'},
            {name: 'priceRetail', value: 'Розн. цена'},
        ]

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.tags['catalog-tree'].tags.treeview.on('nodeselect', node => {
                modal.selectedCategory = node.__selected__ ? node.id : undefined
                let items = modal.tags['catalog-tree'].tags.treeview.getSelectedNodes()
                if (items.length > 0) {
                    let value = items.map(i => i.id).join(',')
                    modal.categoryFilters = [{field: 'idGroup', sign: 'IN', value}]
                } else {
                    modal.categoryFilters = false
                }
                console.log(modal.categoryFilters)
                modal.update()
                modal.tags.catalog.reload()
            })
        })

