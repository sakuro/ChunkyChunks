data:extend({
  -- {
  --   type = 'bool-setting',
  --   name = 'chunkychunks-follow-alt-mode',
  --   setting_type = 'runtime-per-user',
  --   default_value = true,
  --   order = '0-a',
  -- },

  {
    type = 'string-setting',
    name = 'chunkychunks-enabled-1',
    setting_type = 'runtime-per-user',
    default_value = 'ALT-mode',
    allowed_values = {'Disabled', 'ALT-mode', 'Always'},
    order = '1-'
  },{
    type = 'string-setting',
    name = 'chunkychunks-size-1',
    setting_type = 'runtime-per-user',
    default_value = '224',
    order = '1-a',
  },{
    type = 'string-setting',
    name = 'chunkychunks-offset-1',
    setting_type = 'runtime-per-user',
    default_value = '0',
    order = '1-b',
  },{
    type = 'string-setting',
    name = 'chunkychunks-spacing-1',
    setting_type = 'runtime-per-user',
    default_value = '0',
    order = '1-c',
  },{
    type = 'color-setting',
    name = 'chunkychunks-color-1',
    setting_type = 'runtime-per-user',
    default_value = {r = 0, g = 1, b = 0, a = 0.5},
    order = '1-d'
  },{
    type = 'bool-setting',
    name = 'chunkychunks-centre-mark-1',
    setting_type = 'runtime-per-user',
    default_value = true,
    order = '1-e'
  },

  {
    type = 'string-setting',
    name = 'chunkychunks-enabled-2',
    setting_type = 'runtime-per-user',
    default_value = 'ALT-mode',
    allowed_values = {'Disabled', 'ALT-mode', 'Always'},
    order = '2-'
  }, {
    type = 'string-setting',
    name = 'chunkychunks-size-2',
    setting_type = 'runtime-per-user',
    default_value = '32',
    order = '2-a',
  },{
    type = 'string-setting',
    name = 'chunkychunks-offset-2',
    setting_type = 'runtime-per-user',
    default_value = '0',
    order = '2-b',
  },{
    type = 'string-setting',
    name = 'chunkychunks-spacing-2',
    setting_type = 'runtime-per-user',
    default_value = '0',
    order = '2-c',
  },{
    type = 'color-setting',
    name = 'chunkychunks-color-2',
    setting_type = 'runtime-per-user',
    default_value = {r = 0, g = 0, b = 0, a = 0.5},
    order = '2-d'
  },{
    type = 'bool-setting',
    name = 'chunkychunks-centre-mark-2',
    setting_type = 'runtime-per-user',
    default_value = false,
    order = '2-e'
  },

  {
    type = 'string-setting',
    name = 'chunkychunks-enabled-3',
    setting_type = 'runtime-per-user',
    default_value = 'ALT-mode',
    allowed_values = {'Disabled', 'ALT-mode', 'Always'},
    order = '3-'
  },{
    type = 'string-setting',
    name = 'chunkychunks-size-3',
    setting_type = 'runtime-per-user',
    default_value = '0',
    order = '3-a',
  },{
    type = 'string-setting',
    name = 'chunkychunks-offset-3',
    setting_type = 'runtime-per-user',
    default_value = '0',
    order = '3-b',
  },{
    type = 'string-setting',
    name = 'chunkychunks-spacing-3',
    setting_type = 'runtime-per-user',
    default_value = '0',
    order = '3-c',
  },{
    type = 'color-setting',
    name = 'chunkychunks-color-3',
    setting_type = 'runtime-per-user',
    default_value = {r = 1, g = 0, b = 1, a = 0.5},
    order = '3-d'
  },{
    type = 'bool-setting',
    name = 'chunkychunks-centre-mark-3',
    setting_type = 'runtime-per-user',
    default_value = false,
    order = '3-e'
  },
})