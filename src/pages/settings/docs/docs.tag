docs
    h4 Шаблоны документов

    catalog(object='DocTemplate', cols='{ cols }', reload='true', handlers='{ handlers }',
        dblclick='{ docOpen }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='subject') { row.subject }
            datatable-cell(name='recipient') { row.recipient }
            datatable-cell(name='sender') { row.sender }
            datatable-cell(name='target') { row.target }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')

        self.collection = 'DocTemplate'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'}
        ]

        self.docOpen = e => riot.route(`settings/docs/${e.item.row.id}`)

        observable.on('docTemplate-reload', () => {
            self.tags.catalog.reload()
        })
