return {
  settings = {
    yaml = {
      schemastore = { enable = true },
      customTags = {
        '!secret scalar',
        '!include scalar',
        '!include_dir_merge_named scalar',
        '!include_dir_merge_list scalar',
        '!input scalar',
      },
    },
  },
}
