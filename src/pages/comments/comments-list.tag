| import 'components/catalog.tag'
| import 'lodash/lodash'

comments-list
    catalog(search='true', sortable='true', object='Comment', cols='{ cols }', reload='true',
    add='{ permission(add, "comments", "0100") }',
    remove='{ permission(remove, "comments", "0001") }',
    dblclick='{ permission(commentOpen, "comments", "1000") }',
    store='comments-list')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='date') { row.dateDisplay }
            datatable-cell(name='productName') { row.productName }
            datatable-cell(name='userName') { row.userName }
            datatable-cell(name='userEmail') { row.userEmail }
            datatable-cell(name='commentary') { _.truncate(row.commentary.replace( /<.*?>/g, '' ), {length: 50}) }
            datatable-cell(name='response') { _.truncate(row.response.replace( /<.*?>/g, '' ), {length: 50}) }

    script(type='text/babel').
        var self = this

        self.collection = 'Comment'

        self.mixin('permissions')
        self.mixin('remove')

        self.add = () => {
            riot.route('/comments/new')
        }

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'date', value: 'Дата/время'},
            {name: 'productName', value: 'Наименование товара'},
            {name: 'userName', value: 'Пользователь'},
            {name: 'userEmail', value: 'Email пользователя'},
            {name: 'commentary', value: 'Комментарий'},
            {name: 'response', value: 'Ответ администратора'}
        ]

        self.commentOpen = e => {
            riot.route(`/comments/${e.item.row.id}`)
        }

        observable.on('comments-reload', () => {
            self.tags.catalog.reload()
        })


