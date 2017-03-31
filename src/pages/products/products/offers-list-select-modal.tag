offers-list-select-modal
    bs-modal(size='modal-lg')
        #{'yield'}(to="title")
            .h4.modal-title Торговые предложения
        #{'yield'}(to="body")
            .row
                .col-md-3.hidden-xs.hidden-sm
                    catalog-tree(object='Category', label-field='{ "name" }', children-field='{ "childs" }',
                        reload='true', descendants='true')
                .col-md-9.col-xs-12.col-sm-12
                    catalog(object='Product', disable-col-select='true', cols='{ parent.cols }',
                        filters='{ parent.categoryFilters }', search='true', reload='true', sortable='true',
                        dblclick='{ parent.opts.submit.bind(this) }')
                        #{'yield'}(to='body')
                            datatable-cell(name='id') { row.id }
                            datatable-cell(name='name') { row.name }
                            datatable-cell(name='price') { (row.price / 1).toFixed(2) }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'price', value: 'Цена'},
        ]

        self.one('updated', () => {
            self.tags['bs-modal'].tags['catalog-tree'].tags.treeview.on('nodeselect', node => {
                self.selectedCategory = node.__selected__ ? node.id : undefined
                let items = self.tags['bs-modal'].tags['catalog-tree'].tags.treeview.getSelectedNodes()
                if (items.length > 0) {
                    let value = items.map(i => i.id).join(',')
                    self.categoryFilters = [{field: 'idGroup', sign: 'IN', value}]
                } else {
                    self.categoryFilters = false
                }
                self.update()
                self.tags['bs-modal'].tags.catalog.reload()
            })
        })

