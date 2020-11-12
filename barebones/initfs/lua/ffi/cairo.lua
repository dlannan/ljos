local ffi = require( "ffi" )

local cr = ffi.load( "/lib/x86_64-linux-gnu/libcairo.so.2" )

CAIRO_MIME_TYPE_JPEG = "image/jpeg"
CAIRO_MIME_TYPE_PNG  = "image/png"
CAIRO_MIME_TYPE_JP2  = "image/jp2"
CAIRO_MIME_TYPE_URI  = "text/x-uri"

-- #define CAIRO_FONT_TYPE_ATSUI CAIRO_FONT_TYPE_QUARTZ

-- Generated from cairo headers. Do not modify. --
ffi.cdef [[

	int
	cairo_version (void);
	
	 const char*
	cairo_version_string (void);
	typedef int cairo_bool_t;
	typedef struct _cairo cairo_t;
	typedef struct _cairo_surface cairo_surface_t;
	typedef struct _cairo_device cairo_device_t;
	typedef struct _cairo_matrix {
		double xx; double yx;
		double xy; double yy;
		double x0; double y0;
	} cairo_matrix_t;
	typedef struct _cairo_pattern cairo_pattern_t;
	typedef void (*cairo_destroy_func_t) (void *data);
	typedef struct _cairo_user_data_key {
		int unused;
	} cairo_user_data_key_t;
	typedef enum _cairo_status {
		CAIRO_STATUS_SUCCESS = 0,
	
		CAIRO_STATUS_NO_MEMORY,
		CAIRO_STATUS_INVALID_RESTORE,
		CAIRO_STATUS_INVALID_POP_GROUP,
		CAIRO_STATUS_NO_CURRENT_POINT,
		CAIRO_STATUS_INVALID_MATRIX,
		CAIRO_STATUS_INVALID_STATUS,
		CAIRO_STATUS_NULL_POINTER,
		CAIRO_STATUS_INVALID_STRING,
		CAIRO_STATUS_INVALID_PATH_DATA,
		CAIRO_STATUS_READ_ERROR,
		CAIRO_STATUS_WRITE_ERROR,
		CAIRO_STATUS_SURFACE_FINISHED,
		CAIRO_STATUS_SURFACE_TYPE_MISMATCH,
		CAIRO_STATUS_PATTERN_TYPE_MISMATCH,
		CAIRO_STATUS_INVALID_CONTENT,
		CAIRO_STATUS_INVALID_FORMAT,
		CAIRO_STATUS_INVALID_VISUAL,
		CAIRO_STATUS_FILE_NOT_FOUND,
		CAIRO_STATUS_INVALID_DASH,
		CAIRO_STATUS_INVALID_DSC_COMMENT,
		CAIRO_STATUS_INVALID_INDEX,
		CAIRO_STATUS_CLIP_NOT_REPRESENTABLE,
		CAIRO_STATUS_TEMP_FILE_ERROR,
		CAIRO_STATUS_INVALID_STRIDE,
		CAIRO_STATUS_FONT_TYPE_MISMATCH,
		CAIRO_STATUS_USER_FONT_IMMUTABLE,
		CAIRO_STATUS_USER_FONT_ERROR,
		CAIRO_STATUS_NEGATIVE_COUNT,
		CAIRO_STATUS_INVALID_CLUSTERS,
		CAIRO_STATUS_INVALID_SLANT,
		CAIRO_STATUS_INVALID_WEIGHT,
		CAIRO_STATUS_INVALID_SIZE,
		CAIRO_STATUS_USER_FONT_NOT_IMPLEMENTED,
		CAIRO_STATUS_DEVICE_TYPE_MISMATCH,
		CAIRO_STATUS_DEVICE_ERROR,
		CAIRO_STATUS_INVALID_MESH_CONSTRUCTION,
		CAIRO_STATUS_DEVICE_FINISHED,
		CAIRO_STATUS_JBIG2_GLOBAL_MISSING,
		CAIRO_STATUS_PNG_ERROR,
		CAIRO_STATUS_FREETYPE_ERROR,
		CAIRO_STATUS_WIN32_GDI_ERROR,
		CAIRO_STATUS_TAG_ERROR,
	
		CAIRO_STATUS_LAST_STATUS
	} cairo_status_t;
	typedef enum _cairo_content {
		CAIRO_CONTENT_COLOR = 0x1000,
		CAIRO_CONTENT_ALPHA = 0x2000,
		CAIRO_CONTENT_COLOR_ALPHA = 0x3000
	} cairo_content_t;
	typedef enum _cairo_format {
		CAIRO_FORMAT_INVALID = -1,
		CAIRO_FORMAT_ARGB32 = 0,
		CAIRO_FORMAT_RGB24 = 1,
		CAIRO_FORMAT_A8 = 2,
		CAIRO_FORMAT_A1 = 3,
		CAIRO_FORMAT_RGB16_565 = 4,
		CAIRO_FORMAT_RGB30 = 5,
		CAIRO_FORMAT_RGB96F = 6,
		CAIRO_FORMAT_RGBA128F = 7
	} cairo_format_t;
	typedef cairo_status_t (*cairo_write_func_t) (void *closure,
			   const unsigned char *data,
			   unsigned int length);
	typedef cairo_status_t (*cairo_read_func_t) (void *closure,
			  unsigned char *data,
			  unsigned int length);
	typedef struct _cairo_rectangle_int {
		int x, y;
		int width, height;
	} cairo_rectangle_int_t;
	
	
	
	 cairo_t *
	cairo_create (cairo_surface_t *target);
	
	 cairo_t *
	cairo_reference (cairo_t *cr);
	
	 void
	cairo_destroy (cairo_t *cr);
	
	 unsigned int
	cairo_get_reference_count (cairo_t *cr);
	
	 void *
	cairo_get_user_data (cairo_t *cr,
		   const cairo_user_data_key_t *key);
	
	 cairo_status_t
	cairo_set_user_data (cairo_t *cr,
		   const cairo_user_data_key_t *key,
		   void *user_data,
		   cairo_destroy_func_t destroy);
	
	 void
	cairo_save (cairo_t *cr);
	
	 void
	cairo_restore (cairo_t *cr);
	
	 void
	cairo_push_group (cairo_t *cr);
	
	 void
	cairo_push_group_with_content (cairo_t *cr, cairo_content_t content);
	
	 cairo_pattern_t *
	cairo_pop_group (cairo_t *cr);
	
	 void
	cairo_pop_group_to_source (cairo_t *cr);
	typedef enum _cairo_operator {
		CAIRO_OPERATOR_CLEAR,
	
		CAIRO_OPERATOR_SOURCE,
		CAIRO_OPERATOR_OVER,
		CAIRO_OPERATOR_IN,
		CAIRO_OPERATOR_OUT,
		CAIRO_OPERATOR_ATOP,
	
		CAIRO_OPERATOR_DEST,
		CAIRO_OPERATOR_DEST_OVER,
		CAIRO_OPERATOR_DEST_IN,
		CAIRO_OPERATOR_DEST_OUT,
		CAIRO_OPERATOR_DEST_ATOP,
	
		CAIRO_OPERATOR_XOR,
		CAIRO_OPERATOR_ADD,
		CAIRO_OPERATOR_SATURATE,
	
		CAIRO_OPERATOR_MULTIPLY,
		CAIRO_OPERATOR_SCREEN,
		CAIRO_OPERATOR_OVERLAY,
		CAIRO_OPERATOR_DARKEN,
		CAIRO_OPERATOR_LIGHTEN,
		CAIRO_OPERATOR_COLOR_DODGE,
		CAIRO_OPERATOR_COLOR_BURN,
		CAIRO_OPERATOR_HARD_LIGHT,
		CAIRO_OPERATOR_SOFT_LIGHT,
		CAIRO_OPERATOR_DIFFERENCE,
		CAIRO_OPERATOR_EXCLUSION,
		CAIRO_OPERATOR_HSL_HUE,
		CAIRO_OPERATOR_HSL_SATURATION,
		CAIRO_OPERATOR_HSL_COLOR,
		CAIRO_OPERATOR_HSL_LUMINOSITY
	} cairo_operator_t;
	
	 void
	cairo_set_operator (cairo_t *cr, cairo_operator_t op);
	
	 void
	cairo_set_source (cairo_t *cr, cairo_pattern_t *source);
	
	 void
	cairo_set_source_rgb (cairo_t *cr, double red, double green, double blue);
	
	 void
	cairo_set_source_rgba (cairo_t *cr,
			 double red, double green, double blue,
			 double alpha);
	
	 void
	cairo_set_source_surface (cairo_t *cr,
		 cairo_surface_t *surface,
		 double x,
		 double y);
	
	 void
	cairo_set_tolerance (cairo_t *cr, double tolerance);
	typedef enum _cairo_antialias {
		CAIRO_ANTIALIAS_DEFAULT,
	
	
		CAIRO_ANTIALIAS_NONE,
		CAIRO_ANTIALIAS_GRAY,
		CAIRO_ANTIALIAS_SUBPIXEL,
	
	
		CAIRO_ANTIALIAS_FAST,
		CAIRO_ANTIALIAS_GOOD,
		CAIRO_ANTIALIAS_BEST
	} cairo_antialias_t;
	
	 void
	cairo_set_antialias (cairo_t *cr, cairo_antialias_t antialias);
	typedef enum _cairo_fill_rule {
		CAIRO_FILL_RULE_WINDING,
		CAIRO_FILL_RULE_EVEN_ODD
	} cairo_fill_rule_t;
	
	 void
	cairo_set_fill_rule (cairo_t *cr, cairo_fill_rule_t fill_rule);
	
	 void
	cairo_set_line_width (cairo_t *cr, double width);
	typedef enum _cairo_line_cap {
		CAIRO_LINE_CAP_BUTT,
		CAIRO_LINE_CAP_ROUND,
		CAIRO_LINE_CAP_SQUARE
	} cairo_line_cap_t;
	
	 void
	cairo_set_line_cap (cairo_t *cr, cairo_line_cap_t line_cap);
	typedef enum _cairo_line_join {
		CAIRO_LINE_JOIN_MITER,
		CAIRO_LINE_JOIN_ROUND,
		CAIRO_LINE_JOIN_BEVEL
	} cairo_line_join_t;
	
	 void
	cairo_set_line_join (cairo_t *cr, cairo_line_join_t line_join);
	
	 void
	cairo_set_dash (cairo_t *cr,
	  const double *dashes,
	  int num_dashes,
	  double offset);
	
	 void
	cairo_set_miter_limit (cairo_t *cr, double limit);
	
	 void
	cairo_translate (cairo_t *cr, double tx, double ty);
	
	 void
	cairo_scale (cairo_t *cr, double sx, double sy);
	
	 void
	cairo_rotate (cairo_t *cr, double angle);
	
	 void
	cairo_transform (cairo_t *cr,
	   const cairo_matrix_t *matrix);
	
	 void
	cairo_set_matrix (cairo_t *cr,
		const cairo_matrix_t *matrix);
	
	 void
	cairo_identity_matrix (cairo_t *cr);
	
	 void
	cairo_user_to_device (cairo_t *cr, double *x, double *y);
	
	 void
	cairo_user_to_device_distance (cairo_t *cr, double *dx, double *dy);
	
	 void
	cairo_device_to_user (cairo_t *cr, double *x, double *y);
	
	 void
	cairo_device_to_user_distance (cairo_t *cr, double *dx, double *dy);
	
	
	 void
	cairo_new_path (cairo_t *cr);
	
	 void
	cairo_move_to (cairo_t *cr, double x, double y);
	
	 void
	cairo_new_sub_path (cairo_t *cr);
	
	 void
	cairo_line_to (cairo_t *cr, double x, double y);
	
	 void
	cairo_curve_to (cairo_t *cr,
	  double x1, double y1,
	  double x2, double y2,
	  double x3, double y3);
	
	 void
	cairo_arc (cairo_t *cr,
		double xc, double yc,
		double radius,
		double angle1, double angle2);
	
	 void
	cairo_arc_negative (cairo_t *cr,
		  double xc, double yc,
		  double radius,
		  double angle1, double angle2);
	 void
	cairo_rel_move_to (cairo_t *cr, double dx, double dy);
	
	 void
	cairo_rel_line_to (cairo_t *cr, double dx, double dy);
	
	 void
	cairo_rel_curve_to (cairo_t *cr,
		  double dx1, double dy1,
		  double dx2, double dy2,
		  double dx3, double dy3);
	
	 void
	cairo_rectangle (cairo_t *cr,
	   double x, double y,
	   double width, double height);
	
	
	
	
	
	
	 void
	cairo_close_path (cairo_t *cr);
	
	 void
	cairo_path_extents (cairo_t *cr,
		  double *x1, double *y1,
		  double *x2, double *y2);
	
	
	 void
	cairo_paint (cairo_t *cr);
	
	 void
	cairo_paint_with_alpha (cairo_t *cr,
	   double alpha);
	
	 void
	cairo_mask (cairo_t *cr,
		 cairo_pattern_t *pattern);
	
	 void
	cairo_mask_surface (cairo_t *cr,
		  cairo_surface_t *surface,
		  double surface_x,
		  double surface_y);
	
	 void
	cairo_stroke (cairo_t *cr);
	
	 void
	cairo_stroke_preserve (cairo_t *cr);
	
	 void
	cairo_fill (cairo_t *cr);
	
	 void
	cairo_fill_preserve (cairo_t *cr);
	
	 void
	cairo_copy_page (cairo_t *cr);
	
	 void
	cairo_show_page (cairo_t *cr);
	
	
	 cairo_bool_t
	cairo_in_stroke (cairo_t *cr, double x, double y);
	
	 cairo_bool_t
	cairo_in_fill (cairo_t *cr, double x, double y);
	
	 cairo_bool_t
	cairo_in_clip (cairo_t *cr, double x, double y);
	
	
	 void
	cairo_stroke_extents (cairo_t *cr,
			double *x1, double *y1,
			double *x2, double *y2);
	
	 void
	cairo_fill_extents (cairo_t *cr,
		  double *x1, double *y1,
		  double *x2, double *y2);
	
	
	 void
	cairo_reset_clip (cairo_t *cr);
	
	 void
	cairo_clip (cairo_t *cr);
	
	 void
	cairo_clip_preserve (cairo_t *cr);
	
	 void
	cairo_clip_extents (cairo_t *cr,
		  double *x1, double *y1,
		  double *x2, double *y2);
	typedef struct _cairo_rectangle {
		double x, y, width, height;
	} cairo_rectangle_t;
	typedef struct _cairo_rectangle_list {
		cairo_status_t status;
		cairo_rectangle_t *rectangles;
		int num_rectangles;
	} cairo_rectangle_list_t;
	
	 cairo_rectangle_list_t *
	cairo_copy_clip_rectangle_list (cairo_t *cr);
	
	 void
	cairo_rectangle_list_destroy (cairo_rectangle_list_t *rectangle_list);
	
	
	
	
	
	
	 void
	cairo_tag_begin (cairo_t *cr, const char *tag_name, const char *attributes);
	
	 void
	cairo_tag_end (cairo_t *cr, const char *tag_name);
	typedef struct _cairo_scaled_font cairo_scaled_font_t;
	typedef struct _cairo_font_face cairo_font_face_t;
	typedef struct {
		unsigned long index;
		double x;
		double y;
	} cairo_glyph_t;
	
	 cairo_glyph_t *
	cairo_glyph_allocate (int num_glyphs);
	
	 void
	cairo_glyph_free (cairo_glyph_t *glyphs);
	typedef struct {
		int num_bytes;
		int num_glyphs;
	} cairo_text_cluster_t;
	
	 cairo_text_cluster_t *
	cairo_text_cluster_allocate (int num_clusters);
	
	 void
	cairo_text_cluster_free (cairo_text_cluster_t *clusters);
	typedef enum _cairo_text_cluster_flags {
		CAIRO_TEXT_CLUSTER_FLAG_BACKWARD = 0x00000001
	} cairo_text_cluster_flags_t;
	typedef struct {
		double x_bearing;
		double y_bearing;
		double width;
		double height;
		double x_advance;
		double y_advance;
	} cairo_text_extents_t;
	typedef struct {
		double ascent;
		double descent;
		double height;
		double max_x_advance;
		double max_y_advance;
	} cairo_font_extents_t;
	typedef enum _cairo_font_slant {
		CAIRO_FONT_SLANT_NORMAL,
		CAIRO_FONT_SLANT_ITALIC,
		CAIRO_FONT_SLANT_OBLIQUE
	} cairo_font_slant_t;
	typedef enum _cairo_font_weight {
		CAIRO_FONT_WEIGHT_NORMAL,
		CAIRO_FONT_WEIGHT_BOLD
	} cairo_font_weight_t;
	typedef enum _cairo_subpixel_order {
		CAIRO_SUBPIXEL_ORDER_DEFAULT,
		CAIRO_SUBPIXEL_ORDER_RGB,
		CAIRO_SUBPIXEL_ORDER_BGR,
		CAIRO_SUBPIXEL_ORDER_VRGB,
		CAIRO_SUBPIXEL_ORDER_VBGR
	} cairo_subpixel_order_t;
	typedef enum _cairo_hint_style {
		CAIRO_HINT_STYLE_DEFAULT,
		CAIRO_HINT_STYLE_NONE,
		CAIRO_HINT_STYLE_SLIGHT,
		CAIRO_HINT_STYLE_MEDIUM,
		CAIRO_HINT_STYLE_FULL
	} cairo_hint_style_t;
	typedef enum _cairo_hint_metrics {
		CAIRO_HINT_METRICS_DEFAULT,
		CAIRO_HINT_METRICS_OFF,
		CAIRO_HINT_METRICS_ON
	} cairo_hint_metrics_t;
	typedef struct _cairo_font_options cairo_font_options_t;
	
	 cairo_font_options_t *
	cairo_font_options_create (void);
	
	 cairo_font_options_t *
	cairo_font_options_copy (const cairo_font_options_t *original);
	
	 void
	cairo_font_options_destroy (cairo_font_options_t *options);
	
	 cairo_status_t
	cairo_font_options_status (cairo_font_options_t *options);
	
	 void
	cairo_font_options_merge (cairo_font_options_t *options,
		 const cairo_font_options_t *other);
	 cairo_bool_t
	cairo_font_options_equal (const cairo_font_options_t *options,
		 const cairo_font_options_t *other);
	
	 unsigned long
	cairo_font_options_hash (const cairo_font_options_t *options);
	
	 void
	cairo_font_options_set_antialias (cairo_font_options_t *options,
		  cairo_antialias_t antialias);
	 cairo_antialias_t
	cairo_font_options_get_antialias (const cairo_font_options_t *options);
	
	 void
	cairo_font_options_set_subpixel_order (cairo_font_options_t *options,
			   cairo_subpixel_order_t subpixel_order);
	 cairo_subpixel_order_t
	cairo_font_options_get_subpixel_order (const cairo_font_options_t *options);
	
	 void
	cairo_font_options_set_hint_style (cairo_font_options_t *options,
		   cairo_hint_style_t hint_style);
	 cairo_hint_style_t
	cairo_font_options_get_hint_style (const cairo_font_options_t *options);
	
	 void
	cairo_font_options_set_hint_metrics (cairo_font_options_t *options,
			 cairo_hint_metrics_t hint_metrics);
	 cairo_hint_metrics_t
	cairo_font_options_get_hint_metrics (const cairo_font_options_t *options);
	
	 const char *
	cairo_font_options_get_variations (cairo_font_options_t *options);
	
	 void
	cairo_font_options_set_variations (cairo_font_options_t *options,
									   const char *variations);
	
	
	
	
	 void
	cairo_select_font_face (cairo_t *cr,
	   const char *family,
	   cairo_font_slant_t slant,
	   cairo_font_weight_t weight);
	
	 void
	cairo_set_font_size (cairo_t *cr, double size);
	
	 void
	cairo_set_font_matrix (cairo_t *cr,
			 const cairo_matrix_t *matrix);
	
	 void
	cairo_get_font_matrix (cairo_t *cr,
			 cairo_matrix_t *matrix);
	
	 void
	cairo_set_font_options (cairo_t *cr,
	   const cairo_font_options_t *options);
	
	 void
	cairo_get_font_options (cairo_t *cr,
	   cairo_font_options_t *options);
	
	 void
	cairo_set_font_face (cairo_t *cr, cairo_font_face_t *font_face);
	
	 cairo_font_face_t *
	cairo_get_font_face (cairo_t *cr);
	
	 void
	cairo_set_scaled_font (cairo_t *cr,
			 const cairo_scaled_font_t *scaled_font);
	
	 cairo_scaled_font_t *
	cairo_get_scaled_font (cairo_t *cr);
	
	 void
	cairo_show_text (cairo_t *cr, const char *utf8);
	
	 void
	cairo_show_glyphs (cairo_t *cr, const cairo_glyph_t *glyphs, int num_glyphs);
	
	 void
	cairo_show_text_glyphs (cairo_t *cr,
	   const char *utf8,
	   int utf8_len,
	   const cairo_glyph_t *glyphs,
	   int num_glyphs,
	   const cairo_text_cluster_t *clusters,
	   int num_clusters,
	   cairo_text_cluster_flags_t cluster_flags);
	
	 void
	cairo_text_path (cairo_t *cr, const char *utf8);
	
	 void
	cairo_glyph_path (cairo_t *cr, const cairo_glyph_t *glyphs, int num_glyphs);
	
	 void
	cairo_text_extents (cairo_t *cr,
		  const char *utf8,
		  cairo_text_extents_t *extents);
	
	 void
	cairo_glyph_extents (cairo_t *cr,
		   const cairo_glyph_t *glyphs,
		   int num_glyphs,
		   cairo_text_extents_t *extents);
	
	 void
	cairo_font_extents (cairo_t *cr,
		  cairo_font_extents_t *extents);
	
	
	
	 cairo_font_face_t *
	cairo_font_face_reference (cairo_font_face_t *font_face);
	
	 void
	cairo_font_face_destroy (cairo_font_face_t *font_face);
	
	 unsigned int
	cairo_font_face_get_reference_count (cairo_font_face_t *font_face);
	
	 cairo_status_t
	cairo_font_face_status (cairo_font_face_t *font_face);
	typedef enum _cairo_font_type {
		CAIRO_FONT_TYPE_TOY,
		CAIRO_FONT_TYPE_FT,
		CAIRO_FONT_TYPE_WIN32,
		CAIRO_FONT_TYPE_QUARTZ,
		CAIRO_FONT_TYPE_USER
	} cairo_font_type_t;
	
	 cairo_font_type_t
	cairo_font_face_get_type (cairo_font_face_t *font_face);
	
	 void *
	cairo_font_face_get_user_data (cairo_font_face_t *font_face,
			  const cairo_user_data_key_t *key);
	
	 cairo_status_t
	cairo_font_face_set_user_data (cairo_font_face_t *font_face,
			  const cairo_user_data_key_t *key,
			  void *user_data,
			  cairo_destroy_func_t destroy);
	
	
	
	 cairo_scaled_font_t *
	cairo_scaled_font_create (cairo_font_face_t *font_face,
		 const cairo_matrix_t *font_matrix,
		 const cairo_matrix_t *ctm,
		 const cairo_font_options_t *options);
	
	 cairo_scaled_font_t *
	cairo_scaled_font_reference (cairo_scaled_font_t *scaled_font);
	
	 void
	cairo_scaled_font_destroy (cairo_scaled_font_t *scaled_font);
	
	 unsigned int
	cairo_scaled_font_get_reference_count (cairo_scaled_font_t *scaled_font);
	
	 cairo_status_t
	cairo_scaled_font_status (cairo_scaled_font_t *scaled_font);
	
	 cairo_font_type_t
	cairo_scaled_font_get_type (cairo_scaled_font_t *scaled_font);
	
	 void *
	cairo_scaled_font_get_user_data (cairo_scaled_font_t *scaled_font,
		 const cairo_user_data_key_t *key);
	
	 cairo_status_t
	cairo_scaled_font_set_user_data (cairo_scaled_font_t *scaled_font,
		 const cairo_user_data_key_t *key,
		 void *user_data,
		 cairo_destroy_func_t destroy);
	
	 void
	cairo_scaled_font_extents (cairo_scaled_font_t *scaled_font,
		  cairo_font_extents_t *extents);
	
	 void
	cairo_scaled_font_text_extents (cairo_scaled_font_t *scaled_font,
		const char *utf8,
		cairo_text_extents_t *extents);
	
	 void
	cairo_scaled_font_glyph_extents (cairo_scaled_font_t *scaled_font,
		 const cairo_glyph_t *glyphs,
		 int num_glyphs,
		 cairo_text_extents_t *extents);
	
	 cairo_status_t
	cairo_scaled_font_text_to_glyphs (cairo_scaled_font_t *scaled_font,
		  double x,
		  double y,
		  const char *utf8,
		  int utf8_len,
		  cairo_glyph_t **glyphs,
		  int *num_glyphs,
		  cairo_text_cluster_t **clusters,
		  int *num_clusters,
		  cairo_text_cluster_flags_t *cluster_flags);
	
	 cairo_font_face_t *
	cairo_scaled_font_get_font_face (cairo_scaled_font_t *scaled_font);
	
	 void
	cairo_scaled_font_get_font_matrix (cairo_scaled_font_t *scaled_font,
		   cairo_matrix_t *font_matrix);
	
	 void
	cairo_scaled_font_get_ctm (cairo_scaled_font_t *scaled_font,
		  cairo_matrix_t *ctm);
	
	 void
	cairo_scaled_font_get_scale_matrix (cairo_scaled_font_t *scaled_font,
			cairo_matrix_t *scale_matrix);
	
	 void
	cairo_scaled_font_get_font_options (cairo_scaled_font_t *scaled_font,
			cairo_font_options_t *options);
	
	
	
	
	 cairo_font_face_t *
	cairo_toy_font_face_create (const char *family,
		   cairo_font_slant_t slant,
		   cairo_font_weight_t weight);
	
	 const char *
	cairo_toy_font_face_get_family (cairo_font_face_t *font_face);
	
	 cairo_font_slant_t
	cairo_toy_font_face_get_slant (cairo_font_face_t *font_face);
	
	 cairo_font_weight_t
	cairo_toy_font_face_get_weight (cairo_font_face_t *font_face);
	
	
	
	
	 cairo_font_face_t *
	cairo_user_font_face_create (void);
	typedef cairo_status_t (*cairo_user_scaled_font_init_func_t) (cairo_scaled_font_t *scaled_font,
				 cairo_t *cr,
				 cairo_font_extents_t *extents);
	typedef cairo_status_t (*cairo_user_scaled_font_render_glyph_func_t) (cairo_scaled_font_t *scaled_font,
				  unsigned long glyph,
				  cairo_t *cr,
				  cairo_text_extents_t *extents);
	typedef cairo_status_t (*cairo_user_scaled_font_text_to_glyphs_func_t) (cairo_scaled_font_t *scaled_font,
			 const char *utf8,
			 int utf8_len,
			 cairo_glyph_t **glyphs,
			 int *num_glyphs,
			 cairo_text_cluster_t **clusters,
			 int *num_clusters,
			 cairo_text_cluster_flags_t *cluster_flags);
	typedef cairo_status_t (*cairo_user_scaled_font_unicode_to_glyph_func_t) (cairo_scaled_font_t *scaled_font,
			   unsigned long unicode,
			   unsigned long *glyph_index);
	
	
	
	 void
	cairo_user_font_face_set_init_func (cairo_font_face_t *font_face,
			cairo_user_scaled_font_init_func_t init_func);
	
	 void
	cairo_user_font_face_set_render_glyph_func (cairo_font_face_t *font_face,
			 cairo_user_scaled_font_render_glyph_func_t render_glyph_func);
	
	 void
	cairo_user_font_face_set_text_to_glyphs_func (cairo_font_face_t *font_face,
			   cairo_user_scaled_font_text_to_glyphs_func_t text_to_glyphs_func);
	
	 void
	cairo_user_font_face_set_unicode_to_glyph_func (cairo_font_face_t *font_face,
				 cairo_user_scaled_font_unicode_to_glyph_func_t unicode_to_glyph_func);
	
	
	
	 cairo_user_scaled_font_init_func_t
	cairo_user_font_face_get_init_func (cairo_font_face_t *font_face);
	
	 cairo_user_scaled_font_render_glyph_func_t
	cairo_user_font_face_get_render_glyph_func (cairo_font_face_t *font_face);
	
	 cairo_user_scaled_font_text_to_glyphs_func_t
	cairo_user_font_face_get_text_to_glyphs_func (cairo_font_face_t *font_face);
	
	 cairo_user_scaled_font_unicode_to_glyph_func_t
	cairo_user_font_face_get_unicode_to_glyph_func (cairo_font_face_t *font_face);
	
	
	
	
	 cairo_operator_t
	cairo_get_operator (cairo_t *cr);
	
	 cairo_pattern_t *
	cairo_get_source (cairo_t *cr);
	
	 double
	cairo_get_tolerance (cairo_t *cr);
	
	 cairo_antialias_t
	cairo_get_antialias (cairo_t *cr);
	
	 cairo_bool_t
	cairo_has_current_point (cairo_t *cr);
	
	 void
	cairo_get_current_point (cairo_t *cr, double *x, double *y);
	
	 cairo_fill_rule_t
	cairo_get_fill_rule (cairo_t *cr);
	
	 double
	cairo_get_line_width (cairo_t *cr);
	
	 cairo_line_cap_t
	cairo_get_line_cap (cairo_t *cr);
	
	 cairo_line_join_t
	cairo_get_line_join (cairo_t *cr);
	
	 double
	cairo_get_miter_limit (cairo_t *cr);
	
	 int
	cairo_get_dash_count (cairo_t *cr);
	
	 void
	cairo_get_dash (cairo_t *cr, double *dashes, double *offset);
	
	 void
	cairo_get_matrix (cairo_t *cr, cairo_matrix_t *matrix);
	
	 cairo_surface_t *
	cairo_get_target (cairo_t *cr);
	
	 cairo_surface_t *
	cairo_get_group_target (cairo_t *cr);
	typedef enum _cairo_path_data_type {
		CAIRO_PATH_MOVE_TO,
		CAIRO_PATH_LINE_TO,
		CAIRO_PATH_CURVE_TO,
		CAIRO_PATH_CLOSE_PATH
	} cairo_path_data_type_t;
	typedef union _cairo_path_data_t cairo_path_data_t;
	union _cairo_path_data_t {
		struct {
	 cairo_path_data_type_t type;
	 int length;
		} header;
		struct {
	 double x, y;
		} point;
	};
	typedef struct cairo_path {
		cairo_status_t status;
		cairo_path_data_t *data;
		int num_data;
	} cairo_path_t;
	
	 cairo_path_t *
	cairo_copy_path (cairo_t *cr);
	
	 cairo_path_t *
	cairo_copy_path_flat (cairo_t *cr);
	
	 void
	cairo_append_path (cairo_t *cr,
		 const cairo_path_t *path);
	
	 void
	cairo_path_destroy (cairo_path_t *path);
	
	
	
	 cairo_status_t
	cairo_status (cairo_t *cr);
	
	 const char *
	cairo_status_to_string (cairo_status_t status);
	
	
	
	 cairo_device_t *
	cairo_device_reference (cairo_device_t *device);
	typedef enum _cairo_device_type {
		CAIRO_DEVICE_TYPE_DRM,
		CAIRO_DEVICE_TYPE_GL,
		CAIRO_DEVICE_TYPE_SCRIPT,
		CAIRO_DEVICE_TYPE_XCB,
		CAIRO_DEVICE_TYPE_XLIB,
		CAIRO_DEVICE_TYPE_XML,
		CAIRO_DEVICE_TYPE_COGL,
		CAIRO_DEVICE_TYPE_WIN32,
	
		CAIRO_DEVICE_TYPE_INVALID = -1
	} cairo_device_type_t;
	
	 cairo_device_type_t
	cairo_device_get_type (cairo_device_t *device);
	
	 cairo_status_t
	cairo_device_status (cairo_device_t *device);
	
	 cairo_status_t
	cairo_device_acquire (cairo_device_t *device);
	
	 void
	cairo_device_release (cairo_device_t *device);
	
	 void
	cairo_device_flush (cairo_device_t *device);
	
	 void
	cairo_device_finish (cairo_device_t *device);
	
	 void
	cairo_device_destroy (cairo_device_t *device);
	
	 unsigned int
	cairo_device_get_reference_count (cairo_device_t *device);
	
	 void *
	cairo_device_get_user_data (cairo_device_t *device,
		   const cairo_user_data_key_t *key);
	
	 cairo_status_t
	cairo_device_set_user_data (cairo_device_t *device,
		   const cairo_user_data_key_t *key,
		   void *user_data,
		   cairo_destroy_func_t destroy);
	
	
	
	
	 cairo_surface_t *
	cairo_surface_create_similar (cairo_surface_t *other,
			 cairo_content_t content,
			 int width,
			 int height);
	
	 cairo_surface_t *
	cairo_surface_create_similar_image (cairo_surface_t *other,
			cairo_format_t format,
			int width,
			int height);
	
	 cairo_surface_t *
	cairo_surface_map_to_image (cairo_surface_t *surface,
		   const cairo_rectangle_int_t *extents);
	
	 void
	cairo_surface_unmap_image (cairo_surface_t *surface,
		  cairo_surface_t *image);
	
	 cairo_surface_t *
	cairo_surface_create_for_rectangle (cairo_surface_t *target,
										double x,
										double y,
										double width,
										double height);
	typedef enum {
	 CAIRO_SURFACE_OBSERVER_NORMAL = 0,
	 CAIRO_SURFACE_OBSERVER_RECORD_OPERATIONS = 0x1
	} cairo_surface_observer_mode_t;
	
	 cairo_surface_t *
	cairo_surface_create_observer (cairo_surface_t *target,
			  cairo_surface_observer_mode_t mode);
	
	typedef void (*cairo_surface_observer_callback_t) (cairo_surface_t *observer,
			 cairo_surface_t *target,
			 void *data);
	
	 cairo_status_t
	cairo_surface_observer_add_paint_callback (cairo_surface_t *abstract_surface,
			cairo_surface_observer_callback_t func,
			void *data);
	
	 cairo_status_t
	cairo_surface_observer_add_mask_callback (cairo_surface_t *abstract_surface,
		   cairo_surface_observer_callback_t func,
		   void *data);
	
	 cairo_status_t
	cairo_surface_observer_add_fill_callback (cairo_surface_t *abstract_surface,
		   cairo_surface_observer_callback_t func,
		   void *data);
	
	 cairo_status_t
	cairo_surface_observer_add_stroke_callback (cairo_surface_t *abstract_surface,
			 cairo_surface_observer_callback_t func,
			 void *data);
	
	 cairo_status_t
	cairo_surface_observer_add_glyphs_callback (cairo_surface_t *abstract_surface,
			 cairo_surface_observer_callback_t func,
			 void *data);
	
	 cairo_status_t
	cairo_surface_observer_add_flush_callback (cairo_surface_t *abstract_surface,
			cairo_surface_observer_callback_t func,
			void *data);
	
	 cairo_status_t
	cairo_surface_observer_add_finish_callback (cairo_surface_t *abstract_surface,
			 cairo_surface_observer_callback_t func,
			 void *data);
	
	 cairo_status_t
	cairo_surface_observer_print (cairo_surface_t *surface,
			 cairo_write_func_t write_func,
			 void *closure);
	 double
	cairo_surface_observer_elapsed (cairo_surface_t *surface);
	
	 cairo_status_t
	cairo_device_observer_print (cairo_device_t *device,
			cairo_write_func_t write_func,
			void *closure);
	
	 double
	cairo_device_observer_elapsed (cairo_device_t *device);
	
	 double
	cairo_device_observer_paint_elapsed (cairo_device_t *device);
	
	 double
	cairo_device_observer_mask_elapsed (cairo_device_t *device);
	
	 double
	cairo_device_observer_fill_elapsed (cairo_device_t *device);
	
	 double
	cairo_device_observer_stroke_elapsed (cairo_device_t *device);
	
	 double
	cairo_device_observer_glyphs_elapsed (cairo_device_t *device);
	
	 cairo_surface_t *
	cairo_surface_reference (cairo_surface_t *surface);
	
	 void
	cairo_surface_finish (cairo_surface_t *surface);
	
	 void
	cairo_surface_destroy (cairo_surface_t *surface);
	
	 cairo_device_t *
	cairo_surface_get_device (cairo_surface_t *surface);
	
	 unsigned int
	cairo_surface_get_reference_count (cairo_surface_t *surface);
	
	 cairo_status_t
	cairo_surface_status (cairo_surface_t *surface);
	typedef enum _cairo_surface_type {
		CAIRO_SURFACE_TYPE_IMAGE,
		CAIRO_SURFACE_TYPE_PDF,
		CAIRO_SURFACE_TYPE_PS,
		CAIRO_SURFACE_TYPE_XLIB,
		CAIRO_SURFACE_TYPE_XCB,
		CAIRO_SURFACE_TYPE_GLITZ,
		CAIRO_SURFACE_TYPE_QUARTZ,
		CAIRO_SURFACE_TYPE_WIN32,
		CAIRO_SURFACE_TYPE_BEOS,
		CAIRO_SURFACE_TYPE_DIRECTFB,
		CAIRO_SURFACE_TYPE_SVG,
		CAIRO_SURFACE_TYPE_OS2,
		CAIRO_SURFACE_TYPE_WIN32_PRINTING,
		CAIRO_SURFACE_TYPE_QUARTZ_IMAGE,
		CAIRO_SURFACE_TYPE_SCRIPT,
		CAIRO_SURFACE_TYPE_QT,
		CAIRO_SURFACE_TYPE_RECORDING,
		CAIRO_SURFACE_TYPE_VG,
		CAIRO_SURFACE_TYPE_GL,
		CAIRO_SURFACE_TYPE_DRM,
		CAIRO_SURFACE_TYPE_TEE,
		CAIRO_SURFACE_TYPE_XML,
		CAIRO_SURFACE_TYPE_SKIA,
		CAIRO_SURFACE_TYPE_SUBSURFACE,
		CAIRO_SURFACE_TYPE_COGL
	} cairo_surface_type_t;
	
	 cairo_surface_type_t
	cairo_surface_get_type (cairo_surface_t *surface);
	
	 cairo_content_t
	cairo_surface_get_content (cairo_surface_t *surface);
	
	
	
	 cairo_status_t
	cairo_surface_write_to_png (cairo_surface_t *surface,
		   const char *filename);
	
	 cairo_status_t
	cairo_surface_write_to_png_stream (cairo_surface_t *surface,
		   cairo_write_func_t write_func,
		   void *closure);
	
	
	
	 void *
	cairo_surface_get_user_data (cairo_surface_t *surface,
			const cairo_user_data_key_t *key);
	
	 cairo_status_t
	cairo_surface_set_user_data (cairo_surface_t *surface,
			const cairo_user_data_key_t *key,
			void *user_data,
			cairo_destroy_func_t destroy);
	 void
	cairo_surface_get_mime_data (cairo_surface_t *surface,
								 const char *mime_type,
								 const unsigned char **data,
								 unsigned long *length);
	
	 cairo_status_t
	cairo_surface_set_mime_data (cairo_surface_t *surface,
								 const char *mime_type,
								 const unsigned char *data,
								 unsigned long length,
			cairo_destroy_func_t destroy,
			void *closure);
	
	 cairo_bool_t
	cairo_surface_supports_mime_type (cairo_surface_t *surface,
		  const char *mime_type);
	
	 void
	cairo_surface_get_font_options (cairo_surface_t *surface,
		cairo_font_options_t *options);
	
	 void
	cairo_surface_flush (cairo_surface_t *surface);
	
	 void
	cairo_surface_mark_dirty (cairo_surface_t *surface);
	
	 void
	cairo_surface_mark_dirty_rectangle (cairo_surface_t *surface,
			int x,
			int y,
			int width,
			int height);
	
	 void
	cairo_surface_set_device_scale (cairo_surface_t *surface,
		double x_scale,
		double y_scale);
	
	 void
	cairo_surface_get_device_scale (cairo_surface_t *surface,
		double *x_scale,
		double *y_scale);
	
	 void
	cairo_surface_set_device_offset (cairo_surface_t *surface,
		 double x_offset,
		 double y_offset);
	
	 void
	cairo_surface_get_device_offset (cairo_surface_t *surface,
		 double *x_offset,
		 double *y_offset);
	
	 void
	cairo_surface_set_fallback_resolution (cairo_surface_t *surface,
			   double x_pixels_per_inch,
			   double y_pixels_per_inch);
	
	 void
	cairo_surface_get_fallback_resolution (cairo_surface_t *surface,
			   double *x_pixels_per_inch,
			   double *y_pixels_per_inch);
	
	 void
	cairo_surface_copy_page (cairo_surface_t *surface);
	
	 void
	cairo_surface_show_page (cairo_surface_t *surface);
	
	 cairo_bool_t
	cairo_surface_has_show_text_glyphs (cairo_surface_t *surface);
	
	
	
	 cairo_surface_t *
	cairo_image_surface_create (cairo_format_t format,
		   int width,
		   int height);
	
	 int
	cairo_format_stride_for_width (cairo_format_t format,
			  int width);
	
	 cairo_surface_t *
	cairo_image_surface_create_for_data (unsigned char *data,
			 cairo_format_t format,
			 int width,
			 int height,
			 int stride);
	
	 unsigned char *
	cairo_image_surface_get_data (cairo_surface_t *surface);
	
	 cairo_format_t
	cairo_image_surface_get_format (cairo_surface_t *surface);
	
	 int
	cairo_image_surface_get_width (cairo_surface_t *surface);
	
	 int
	cairo_image_surface_get_height (cairo_surface_t *surface);
	
	 int
	cairo_image_surface_get_stride (cairo_surface_t *surface);
	
	
	
	 cairo_surface_t *
	cairo_image_surface_create_from_png (const char *filename);
	
	 cairo_surface_t *
	cairo_image_surface_create_from_png_stream (cairo_read_func_t read_func,
			 void *closure);
	
	
	
	
	
	 cairo_surface_t *
	cairo_recording_surface_create (cairo_content_t content,
									const cairo_rectangle_t *extents);
	
	 void
	cairo_recording_surface_ink_extents (cairo_surface_t *surface,
										 double *x0,
										 double *y0,
										 double *width,
										 double *height);
	
	 cairo_bool_t
	cairo_recording_surface_get_extents (cairo_surface_t *surface,
			 cairo_rectangle_t *extents);
	typedef cairo_surface_t *
	(*cairo_raster_source_acquire_func_t) (cairo_pattern_t *pattern,
			   void *callback_data,
			   cairo_surface_t *target,
			   const cairo_rectangle_int_t *extents);
	typedef void
	(*cairo_raster_source_release_func_t) (cairo_pattern_t *pattern,
			   void *callback_data,
			   cairo_surface_t *surface);
	typedef cairo_status_t
	(*cairo_raster_source_snapshot_func_t) (cairo_pattern_t *pattern,
		 void *callback_data);
	typedef cairo_status_t
	(*cairo_raster_source_copy_func_t) (cairo_pattern_t *pattern,
			void *callback_data,
			const cairo_pattern_t *other);
	typedef void
	(*cairo_raster_source_finish_func_t) (cairo_pattern_t *pattern,
			  void *callback_data);
	
	 cairo_pattern_t *
	cairo_pattern_create_raster_source (void *user_data,
			cairo_content_t content,
			int width, int height);
	
	 void
	cairo_raster_source_pattern_set_callback_data (cairo_pattern_t *pattern,
				void *data);
	
	 void *
	cairo_raster_source_pattern_get_callback_data (cairo_pattern_t *pattern);
	
	 void
	cairo_raster_source_pattern_set_acquire (cairo_pattern_t *pattern,
		  cairo_raster_source_acquire_func_t acquire,
		  cairo_raster_source_release_func_t release);
	
	 void
	cairo_raster_source_pattern_get_acquire (cairo_pattern_t *pattern,
		  cairo_raster_source_acquire_func_t *acquire,
		  cairo_raster_source_release_func_t *release);
	 void
	cairo_raster_source_pattern_set_snapshot (cairo_pattern_t *pattern,
		   cairo_raster_source_snapshot_func_t snapshot);
	
	 cairo_raster_source_snapshot_func_t
	cairo_raster_source_pattern_get_snapshot (cairo_pattern_t *pattern);
	
	 void
	cairo_raster_source_pattern_set_copy (cairo_pattern_t *pattern,
			  cairo_raster_source_copy_func_t copy);
	
	 cairo_raster_source_copy_func_t
	cairo_raster_source_pattern_get_copy (cairo_pattern_t *pattern);
	
	 void
	cairo_raster_source_pattern_set_finish (cairo_pattern_t *pattern,
		 cairo_raster_source_finish_func_t finish);
	
	 cairo_raster_source_finish_func_t
	cairo_raster_source_pattern_get_finish (cairo_pattern_t *pattern);
	
	
	
	 cairo_pattern_t *
	cairo_pattern_create_rgb (double red, double green, double blue);
	
	 cairo_pattern_t *
	cairo_pattern_create_rgba (double red, double green, double blue,
		  double alpha);
	
	 cairo_pattern_t *
	cairo_pattern_create_for_surface (cairo_surface_t *surface);
	
	 cairo_pattern_t *
	cairo_pattern_create_linear (double x0, double y0,
			double x1, double y1);
	
	 cairo_pattern_t *
	cairo_pattern_create_radial (double cx0, double cy0, double radius0,
			double cx1, double cy1, double radius1);
	
	 cairo_pattern_t *
	cairo_pattern_create_mesh (void);
	
	 cairo_pattern_t *
	cairo_pattern_reference (cairo_pattern_t *pattern);
	
	 void
	cairo_pattern_destroy (cairo_pattern_t *pattern);
	
	 unsigned int
	cairo_pattern_get_reference_count (cairo_pattern_t *pattern);
	
	 cairo_status_t
	cairo_pattern_status (cairo_pattern_t *pattern);
	
	 void *
	cairo_pattern_get_user_data (cairo_pattern_t *pattern,
			const cairo_user_data_key_t *key);
	
	 cairo_status_t
	cairo_pattern_set_user_data (cairo_pattern_t *pattern,
			const cairo_user_data_key_t *key,
			void *user_data,
			cairo_destroy_func_t destroy);
	typedef enum _cairo_pattern_type {
		CAIRO_PATTERN_TYPE_SOLID,
		CAIRO_PATTERN_TYPE_SURFACE,
		CAIRO_PATTERN_TYPE_LINEAR,
		CAIRO_PATTERN_TYPE_RADIAL,
		CAIRO_PATTERN_TYPE_MESH,
		CAIRO_PATTERN_TYPE_RASTER_SOURCE
	} cairo_pattern_type_t;
	
	 cairo_pattern_type_t
	cairo_pattern_get_type (cairo_pattern_t *pattern);
	
	 void
	cairo_pattern_add_color_stop_rgb (cairo_pattern_t *pattern,
		  double offset,
		  double red, double green, double blue);
	
	 void
	cairo_pattern_add_color_stop_rgba (cairo_pattern_t *pattern,
		   double offset,
		   double red, double green, double blue,
		   double alpha);
	
	 void
	cairo_mesh_pattern_begin_patch (cairo_pattern_t *pattern);
	
	 void
	cairo_mesh_pattern_end_patch (cairo_pattern_t *pattern);
	
	 void
	cairo_mesh_pattern_curve_to (cairo_pattern_t *pattern,
			double x1, double y1,
			double x2, double y2,
			double x3, double y3);
	
	 void
	cairo_mesh_pattern_line_to (cairo_pattern_t *pattern,
		   double x, double y);
	
	 void
	cairo_mesh_pattern_move_to (cairo_pattern_t *pattern,
		   double x, double y);
	
	 void
	cairo_mesh_pattern_set_control_point (cairo_pattern_t *pattern,
			  unsigned int point_num,
			  double x, double y);
	
	 void
	cairo_mesh_pattern_set_corner_color_rgb (cairo_pattern_t *pattern,
		  unsigned int corner_num,
		  double red, double green, double blue);
	
	 void
	cairo_mesh_pattern_set_corner_color_rgba (cairo_pattern_t *pattern,
		   unsigned int corner_num,
		   double red, double green, double blue,
		   double alpha);
	
	 void
	cairo_pattern_set_matrix (cairo_pattern_t *pattern,
		 const cairo_matrix_t *matrix);
	
	 void
	cairo_pattern_get_matrix (cairo_pattern_t *pattern,
		 cairo_matrix_t *matrix);
	typedef enum _cairo_extend {
		CAIRO_EXTEND_NONE,
		CAIRO_EXTEND_REPEAT,
		CAIRO_EXTEND_REFLECT,
		CAIRO_EXTEND_PAD
	} cairo_extend_t;
	
	 void
	cairo_pattern_set_extend (cairo_pattern_t *pattern, cairo_extend_t extend);
	
	 cairo_extend_t
	cairo_pattern_get_extend (cairo_pattern_t *pattern);
	typedef enum _cairo_filter {
		CAIRO_FILTER_FAST,
		CAIRO_FILTER_GOOD,
		CAIRO_FILTER_BEST,
		CAIRO_FILTER_NEAREST,
		CAIRO_FILTER_BILINEAR,
		CAIRO_FILTER_GAUSSIAN
	} cairo_filter_t;
	
	 void
	cairo_pattern_set_filter (cairo_pattern_t *pattern, cairo_filter_t filter);
	
	 cairo_filter_t
	cairo_pattern_get_filter (cairo_pattern_t *pattern);
	
	 cairo_status_t
	cairo_pattern_get_rgba (cairo_pattern_t *pattern,
	   double *red, double *green,
	   double *blue, double *alpha);
	
	 cairo_status_t
	cairo_pattern_get_surface (cairo_pattern_t *pattern,
		  cairo_surface_t **surface);
	
	
	 cairo_status_t
	cairo_pattern_get_color_stop_rgba (cairo_pattern_t *pattern,
		   int index, double *offset,
		   double *red, double *green,
		   double *blue, double *alpha);
	
	 cairo_status_t
	cairo_pattern_get_color_stop_count (cairo_pattern_t *pattern,
			int *count);
	
	 cairo_status_t
	cairo_pattern_get_linear_points (cairo_pattern_t *pattern,
		 double *x0, double *y0,
		 double *x1, double *y1);
	
	 cairo_status_t
	cairo_pattern_get_radial_circles (cairo_pattern_t *pattern,
		  double *x0, double *y0, double *r0,
		  double *x1, double *y1, double *r1);
	
	 cairo_status_t
	cairo_mesh_pattern_get_patch_count (cairo_pattern_t *pattern,
			unsigned int *count);
	
	 cairo_path_t *
	cairo_mesh_pattern_get_path (cairo_pattern_t *pattern,
			unsigned int patch_num);
	
	 cairo_status_t
	cairo_mesh_pattern_get_corner_color_rgba (cairo_pattern_t *pattern,
		   unsigned int patch_num,
		   unsigned int corner_num,
		   double *red, double *green,
		   double *blue, double *alpha);
	
	 cairo_status_t
	cairo_mesh_pattern_get_control_point (cairo_pattern_t *pattern,
			  unsigned int patch_num,
			  unsigned int point_num,
			  double *x, double *y);
	
	
	
	 void
	cairo_matrix_init (cairo_matrix_t *matrix,
		 double xx, double yx,
		 double xy, double yy,
		 double x0, double y0);
	
	 void
	cairo_matrix_init_identity (cairo_matrix_t *matrix);
	
	 void
	cairo_matrix_init_translate (cairo_matrix_t *matrix,
			double tx, double ty);
	
	 void
	cairo_matrix_init_scale (cairo_matrix_t *matrix,
		double sx, double sy);
	
	 void
	cairo_matrix_init_rotate (cairo_matrix_t *matrix,
		 double radians);
	
	 void
	cairo_matrix_translate (cairo_matrix_t *matrix, double tx, double ty);
	
	 void
	cairo_matrix_scale (cairo_matrix_t *matrix, double sx, double sy);
	
	 void
	cairo_matrix_rotate (cairo_matrix_t *matrix, double radians);
	
	 cairo_status_t
	cairo_matrix_invert (cairo_matrix_t *matrix);
	
	 void
	cairo_matrix_multiply (cairo_matrix_t *result,
			 const cairo_matrix_t *a,
			 const cairo_matrix_t *b);
	
	 void
	cairo_matrix_transform_distance (const cairo_matrix_t *matrix,
		 double *dx, double *dy);
	
	 void
	cairo_matrix_transform_point (const cairo_matrix_t *matrix,
			 double *x, double *y);
	typedef struct _cairo_region cairo_region_t;
	typedef enum _cairo_region_overlap {
		CAIRO_REGION_OVERLAP_IN,
		CAIRO_REGION_OVERLAP_OUT,
		CAIRO_REGION_OVERLAP_PART
	} cairo_region_overlap_t;
	
	 cairo_region_t *
	cairo_region_create (void);
	
	 cairo_region_t *
	cairo_region_create_rectangle (const cairo_rectangle_int_t *rectangle);
	
	 cairo_region_t *
	cairo_region_create_rectangles (const cairo_rectangle_int_t *rects,
		int count);
	
	 cairo_region_t *
	cairo_region_copy (const cairo_region_t *original);
	
	 cairo_region_t *
	cairo_region_reference (cairo_region_t *region);
	
	 void
	cairo_region_destroy (cairo_region_t *region);
	
	 cairo_bool_t
	cairo_region_equal (const cairo_region_t *a, const cairo_region_t *b);
	
	 cairo_status_t
	cairo_region_status (const cairo_region_t *region);
	
	 void
	cairo_region_get_extents (const cairo_region_t *region,
		 cairo_rectangle_int_t *extents);
	
	 int
	cairo_region_num_rectangles (const cairo_region_t *region);
	
	 void
	cairo_region_get_rectangle (const cairo_region_t *region,
		   int nth,
		   cairo_rectangle_int_t *rectangle);
	
	 cairo_bool_t
	cairo_region_is_empty (const cairo_region_t *region);
	
	 cairo_region_overlap_t
	cairo_region_contains_rectangle (const cairo_region_t *region,
		 const cairo_rectangle_int_t *rectangle);
	
	 cairo_bool_t
	cairo_region_contains_point (const cairo_region_t *region, int x, int y);
	
	 void
	cairo_region_translate (cairo_region_t *region, int dx, int dy);
	
	 cairo_status_t
	cairo_region_subtract (cairo_region_t *dst, const cairo_region_t *other);
	
	 cairo_status_t
	cairo_region_subtract_rectangle (cairo_region_t *dst,
		 const cairo_rectangle_int_t *rectangle);
	
	 cairo_status_t
	cairo_region_intersect (cairo_region_t *dst, const cairo_region_t *other);
	
	 cairo_status_t
	cairo_region_intersect_rectangle (cairo_region_t *dst,
		  const cairo_rectangle_int_t *rectangle);
	
	 cairo_status_t
	cairo_region_union (cairo_region_t *dst, const cairo_region_t *other);
	
	 cairo_status_t
	cairo_region_union_rectangle (cairo_region_t *dst,
			 const cairo_rectangle_int_t *rectangle);
	
	 cairo_status_t
	cairo_region_xor (cairo_region_t *dst, const cairo_region_t *other);
	
	 cairo_status_t
	cairo_region_xor_rectangle (cairo_region_t *dst,
		   const cairo_rectangle_int_t *rectangle);
	
	
	 void
	cairo_debug_reset_static_data (void);
	
	
	
	typedef struct _cairo_uint64 {
		uint32_t lo, hi;
	} cairo_uint64_t, cairo_int64_t;
	typedef struct _cairo_uquorem64 {
		cairo_uint64_t quo;
		cairo_uint64_t rem;
	} cairo_uquorem64_t;
	
	typedef struct _cairo_quorem64 {
		cairo_int64_t quo;
		cairo_int64_t rem;
	} cairo_quorem64_t;
	typedef struct cairo_uint128 {
		cairo_uint64_t lo, hi;
	} cairo_uint128_t, cairo_int128_t;
	typedef struct _cairo_uquorem128 {
		cairo_uint128_t quo;
		cairo_uint128_t rem;
	} cairo_uquorem128_t;
	
	typedef struct _cairo_quorem128 {
		cairo_int128_t quo;
		cairo_int128_t rem;
	} cairo_quorem128_t;
	
	
	
	
	
	typedef int32_t cairo_fixed_16_16_t;
	typedef cairo_int64_t cairo_fixed_32_32_t;
	typedef cairo_int64_t cairo_fixed_48_16_t;
	typedef cairo_int128_t cairo_fixed_64_64_t;
	typedef cairo_int128_t cairo_fixed_96_32_t;
	typedef int32_t cairo_fixed_t;
	
	
	typedef uint32_t cairo_fixed_unsigned_t;
	
	typedef struct _cairo_point {
		cairo_fixed_t x;
		cairo_fixed_t y;
	} cairo_point_t;
	
	
	
	typedef struct _cairo_list {
		struct _cairo_list *next, *prev;
	} cairo_list_t;
	
	
	
	
	
	
	
	
	typedef unsigned int cairo_atomic_intptr_t;
	typedef cairo_atomic_intptr_t cairo_atomic_int_t;
	
	__attribute__((__visibility__("hidden"))) void
	_cairo_atomic_int_inc (cairo_atomic_int_t *x);
	
	
	
	__attribute__((__visibility__("hidden"))) cairo_bool_t
	_cairo_atomic_int_dec_and_test (cairo_atomic_int_t *x);
	
	__attribute__((__visibility__("hidden"))) cairo_atomic_int_t
	_cairo_atomic_int_cmpxchg_return_old_impl (cairo_atomic_int_t *x, cairo_atomic_int_t oldv, cairo_atomic_int_t newv);
	
	__attribute__((__visibility__("hidden"))) void *
	_cairo_atomic_ptr_cmpxchg_return_old_impl (void **x, void *oldv, void *newv);
	typedef cairo_atomic_int_t cairo_atomic_once_t;
	
	
	
	
	
	
	static inline __attribute__((always_inline)) cairo_bool_t
	_cairo_atomic_init_once_enter(cairo_atomic_once_t *once)
	{
		if (((*once) == (2)))
	 return 0;
	
		if ((_cairo_atomic_int_cmpxchg_return_old_impl (once, (0), (1)) == (0))
	
										 )
	 return 1;
	
		while ((*once) != (2)) {}
		return 0;
	}
	
	static inline __attribute__((always_inline)) void
	_cairo_atomic_init_once_leave(cairo_atomic_once_t *once)
	{
		if ((!(_cairo_atomic_int_cmpxchg_return_old_impl (once, (1), (2)) == (1)))
	
											)
	 assert (0 && "incorrect use of _cairo_atomic_init_once API (once != CAIRO_ATOMIC_ONCE_INITIALIZING)");
	}
	
	
	
	
	typedef struct {
		cairo_atomic_int_t ref_count;
	} cairo_reference_count_t;
	
	
	typedef struct _cairo_array cairo_array_t;
	typedef struct _cairo_backend cairo_backend_t;
	typedef struct _cairo_boxes_t cairo_boxes_t;
	typedef struct _cairo_cache cairo_cache_t;
	typedef struct _cairo_composite_rectangles cairo_composite_rectangles_t;
	typedef struct _cairo_clip cairo_clip_t;
	typedef struct _cairo_clip_path cairo_clip_path_t;
	typedef struct _cairo_color cairo_color_t;
	typedef struct _cairo_color_stop cairo_color_stop_t;
	typedef struct _cairo_contour cairo_contour_t;
	typedef struct _cairo_contour_chain cairo_contour_chain_t;
	typedef struct _cairo_contour_iter cairo_contour_iter_t;
	typedef struct _cairo_damage cairo_damage_t;
	typedef struct _cairo_device_backend cairo_device_backend_t;
	typedef struct _cairo_font_face_backend cairo_font_face_backend_t;
	typedef struct _cairo_gstate cairo_gstate_t;
	typedef struct _cairo_gstate_backend cairo_gstate_backend_t;
	typedef struct _cairo_glyph_text_info cairo_glyph_text_info_t;
	typedef struct _cairo_hash_entry cairo_hash_entry_t;
	typedef struct _cairo_hash_table cairo_hash_table_t;
	typedef struct _cairo_image_surface cairo_image_surface_t;
	typedef struct _cairo_mime_data cairo_mime_data_t;
	typedef struct _cairo_observer cairo_observer_t;
	typedef struct _cairo_output_stream cairo_output_stream_t;
	typedef struct _cairo_paginated_surface_backend cairo_paginated_surface_backend_t;
	typedef struct _cairo_path_fixed cairo_path_fixed_t;
	typedef struct _cairo_rectangle_int16 cairo_glyph_size_t;
	typedef struct _cairo_scaled_font_subsets cairo_scaled_font_subsets_t;
	typedef struct _cairo_solid_pattern cairo_solid_pattern_t;
	typedef struct _cairo_surface_attributes cairo_surface_attributes_t;
	typedef struct _cairo_surface_backend cairo_surface_backend_t;
	typedef struct _cairo_surface_observer cairo_surface_observer_t;
	typedef struct _cairo_surface_snapshot cairo_surface_snapshot_t;
	typedef struct _cairo_surface_subsurface cairo_surface_subsurface_t;
	typedef struct _cairo_surface_wrapper cairo_surface_wrapper_t;
	typedef struct _cairo_traps cairo_traps_t;
	typedef struct _cairo_tristrip cairo_tristrip_t;
	typedef struct _cairo_unscaled_font_backend cairo_unscaled_font_backend_t;
	typedef struct _cairo_xlib_screen_info cairo_xlib_screen_info_t;
	
	typedef cairo_array_t cairo_user_data_array_t;
	
	typedef struct _cairo_scaled_font_private cairo_scaled_font_private_t;
	typedef struct _cairo_scaled_font_backend cairo_scaled_font_backend_t;
	typedef struct _cairo_scaled_glyph cairo_scaled_glyph_t;
	typedef struct _cairo_scaled_glyph_private cairo_scaled_glyph_private_t;
	
	typedef struct cairo_compositor cairo_compositor_t;
	typedef struct cairo_fallback_compositor cairo_fallback_compositor_t;
	typedef struct cairo_mask_compositor cairo_mask_compositor_t;
	typedef struct cairo_traps_compositor cairo_traps_compositor_t;
	typedef struct cairo_spans_compositor cairo_spans_compositor_t;
	
	struct _cairo_observer {
		cairo_list_t link;
		void (*callback) (cairo_observer_t *self, void *arg);
	};
	struct _cairo_hash_entry {
		unsigned long hash;
	};
	
	struct _cairo_array {
		unsigned int size;
		unsigned int num_elements;
		unsigned int element_size;
		char *elements;
	};
	typedef enum _cairo_lcd_filter {
		CAIRO_LCD_FILTER_DEFAULT,
		CAIRO_LCD_FILTER_NONE,
		CAIRO_LCD_FILTER_INTRA_PIXEL,
		CAIRO_LCD_FILTER_FIR3,
		CAIRO_LCD_FILTER_FIR5
	} cairo_lcd_filter_t;
	
	typedef enum _cairo_round_glyph_positions {
		CAIRO_ROUND_GLYPH_POS_DEFAULT,
		CAIRO_ROUND_GLYPH_POS_ON,
		CAIRO_ROUND_GLYPH_POS_OFF
	} cairo_round_glyph_positions_t;
	
	struct _cairo_font_options {
		cairo_antialias_t antialias;
		cairo_subpixel_order_t subpixel_order;
		cairo_lcd_filter_t lcd_filter;
		cairo_hint_style_t hint_style;
		cairo_hint_metrics_t hint_metrics;
		cairo_round_glyph_positions_t round_glyph_positions;
		char *variations;
	};
	
	struct _cairo_glyph_text_info {
		const char *utf8;
		int utf8_len;
	
		const cairo_text_cluster_t *clusters;
		int num_clusters;
		cairo_text_cluster_flags_t cluster_flags;
	};
	struct _cairo_color {
		double red;
		double green;
		double blue;
		double alpha;
	
		unsigned short red_short;
		unsigned short green_short;
		unsigned short blue_short;
		unsigned short alpha_short;
	};
	
	struct _cairo_color_stop {
	
		double red;
		double green;
		double blue;
		double alpha;
	
	
		uint16_t red_short;
		uint16_t green_short;
		uint16_t blue_short;
		uint16_t alpha_short;
	};
	
	typedef enum _cairo_paginated_mode {
		CAIRO_PAGINATED_MODE_ANALYZE,
		CAIRO_PAGINATED_MODE_RENDER,
		CAIRO_PAGINATED_MODE_FALLBACK
	} cairo_paginated_mode_t;
	
	typedef enum _cairo_internal_surface_type {
		CAIRO_INTERNAL_SURFACE_TYPE_SNAPSHOT = 0x1000,
		CAIRO_INTERNAL_SURFACE_TYPE_PAGINATED,
		CAIRO_INTERNAL_SURFACE_TYPE_ANALYSIS,
		CAIRO_INTERNAL_SURFACE_TYPE_OBSERVER,
		CAIRO_INTERNAL_SURFACE_TYPE_TEST_FALLBACK,
		CAIRO_INTERNAL_SURFACE_TYPE_TEST_PAGINATED,
		CAIRO_INTERNAL_SURFACE_TYPE_TEST_WRAPPING,
		CAIRO_INTERNAL_SURFACE_TYPE_NULL,
		CAIRO_INTERNAL_SURFACE_TYPE_TYPE3_GLYPH
	} cairo_internal_surface_type_t;
	
	typedef enum _cairo_internal_device_type {
		CAIRO_INTERNAL_DEVICE_TYPE_OBSERVER = 0x1000,
	} cairo_device_surface_type_t;
	
	
	
	typedef struct _cairo_slope {
		cairo_fixed_t dx;
		cairo_fixed_t dy;
	} cairo_slope_t, cairo_distance_t;
	
	typedef struct _cairo_point_double {
		double x;
		double y;
	} cairo_point_double_t;
	
	typedef struct _cairo_circle_double {
		cairo_point_double_t center;
		double radius;
	} cairo_circle_double_t;
	
	typedef struct _cairo_distance_double {
		double dx;
		double dy;
	} cairo_distance_double_t;
	
	typedef struct _cairo_box_double {
		cairo_point_double_t p1;
		cairo_point_double_t p2;
	} cairo_box_double_t;
	
	typedef struct _cairo_line {
		cairo_point_t p1;
		cairo_point_t p2;
	} cairo_line_t, cairo_box_t;
	
	typedef struct _cairo_trapezoid {
		cairo_fixed_t top, bottom;
		cairo_line_t left, right;
	} cairo_trapezoid_t;
	
	typedef struct _cairo_point_int {
		int x, y;
	} cairo_point_int_t;
	
	
	
	
	typedef enum _cairo_direction {
		CAIRO_DIRECTION_FORWARD,
		CAIRO_DIRECTION_REVERSE
	} cairo_direction_t;
	
	typedef struct _cairo_edge {
		cairo_line_t line;
		int top, bottom;
		int dir;
	} cairo_edge_t;
	
	typedef struct _cairo_polygon {
		cairo_status_t status;
	
		cairo_box_t extents;
		cairo_box_t limit;
		const cairo_box_t *limits;
		int num_limits;
	
		int num_edges;
		int edges_size;
		cairo_edge_t *edges;
		cairo_edge_t edges_embedded[32];
	} cairo_polygon_t;
	
	typedef cairo_status_t
	(*cairo_spline_add_point_func_t) (void *closure,
		  const cairo_point_t *point,
		  const cairo_slope_t *tangent);
	
	typedef struct _cairo_spline_knots {
		cairo_point_t a, b, c, d;
	} cairo_spline_knots_t;
	
	typedef struct _cairo_spline {
		cairo_spline_add_point_func_t add_point_func;
		void *closure;
	
		cairo_spline_knots_t knots;
	
		cairo_slope_t initial_slope;
		cairo_slope_t final_slope;
	
		cairo_bool_t has_point;
		cairo_point_t last_point;
	} cairo_spline_t;
	
	typedef struct _cairo_pen_vertex {
		cairo_point_t point;
	
		cairo_slope_t slope_ccw;
		cairo_slope_t slope_cw;
	} cairo_pen_vertex_t;
	
	typedef struct _cairo_pen {
		double radius;
		double tolerance;
	
		int num_vertices;
		cairo_pen_vertex_t *vertices;
		cairo_pen_vertex_t vertices_embedded[32];
	} cairo_pen_t;
	
	typedef struct _cairo_stroke_style {
		double line_width;
		cairo_line_cap_t line_cap;
		cairo_line_join_t line_join;
		double miter_limit;
		double *dash;
		unsigned int num_dashes;
		double dash_offset;
	} cairo_stroke_style_t;
	
	typedef struct _cairo_format_masks {
		int bpp;
		unsigned long alpha_mask;
		unsigned long red_mask;
		unsigned long green_mask;
		unsigned long blue_mask;
	} cairo_format_masks_t;
	
	typedef enum {
		CAIRO_STOCK_WHITE,
		CAIRO_STOCK_BLACK,
		CAIRO_STOCK_TRANSPARENT,
		CAIRO_STOCK_NUM_COLORS,
	} cairo_stock_t;
	
	typedef enum _cairo_image_transparency {
		CAIRO_IMAGE_IS_OPAQUE,
		CAIRO_IMAGE_HAS_BILEVEL_ALPHA,
		CAIRO_IMAGE_HAS_ALPHA,
		CAIRO_IMAGE_UNKNOWN
	} cairo_image_transparency_t;
	
	typedef enum _cairo_image_color {
		CAIRO_IMAGE_IS_COLOR,
		CAIRO_IMAGE_IS_GRAYSCALE,
		CAIRO_IMAGE_IS_MONOCHROME,
		CAIRO_IMAGE_UNKNOWN_COLOR
	} cairo_image_color_t;
	
	
	struct _cairo_mime_data {
		cairo_reference_count_t ref_count;
		unsigned char *data;
		unsigned long length;
		cairo_destroy_func_t destroy;
		void *closure;
	};
	
	
	
	
	
	typedef struct _cairo_unscaled_font {
		cairo_hash_entry_t hash_entry;
		cairo_reference_count_t ref_count;
		const cairo_unscaled_font_backend_t *backend;
	} cairo_unscaled_font_t;
	
	
	
	
	
	struct _cairo {
		cairo_reference_count_t ref_count;
		cairo_status_t status;
		cairo_user_data_array_t user_data;
	
		const cairo_backend_t *backend;
	};
	
	__attribute__((__visibility__("hidden"))) cairo_t *
	_cairo_create_in_error (cairo_status_t status);
	
	__attribute__((__visibility__("hidden"))) void
	_cairo_init (cairo_t *cr,
		  const cairo_backend_t *backend);
	
	__attribute__((__visibility__("hidden"))) void
	_cairo_fini (cairo_t *cr);
	
	
	 cairo_font_face_t *
	cairo_ft_font_face_create_for_ft_face (FT_Face face,
			   int load_flags);
	typedef enum {
		CAIRO_FT_SYNTHESIZE_BOLD = 1 << 0,
		CAIRO_FT_SYNTHESIZE_OBLIQUE = 1 << 1
	} cairo_ft_synthesize_t;
	
	 void
	cairo_ft_font_face_set_synthesize (cairo_font_face_t *font_face,
		   unsigned int synth_flags);
	
	 void
	cairo_ft_font_face_unset_synthesize (cairo_font_face_t *font_face,
			 unsigned int synth_flags);
	
	 unsigned int
	cairo_ft_font_face_get_synthesize (cairo_font_face_t *font_face);
	
	
	 FT_Face
	cairo_ft_scaled_font_lock_face (cairo_scaled_font_t *scaled_font);
	
	 void
	cairo_ft_scaled_font_unlock_face (cairo_scaled_font_t *scaled_font);
	
	
	typedef enum _cairo_pdf_version {
		CAIRO_PDF_VERSION_1_4,
		CAIRO_PDF_VERSION_1_5
	} cairo_pdf_version_t;
	
	 cairo_surface_t *
	cairo_pdf_surface_create (const char *filename,
		 double width_in_points,
		 double height_in_points);
	
	 cairo_surface_t *
	cairo_pdf_surface_create_for_stream (cairo_write_func_t write_func,
			 void *closure,
			 double width_in_points,
			 double height_in_points);
	
	 void
	cairo_pdf_surface_restrict_to_version (cairo_surface_t *surface,
			   cairo_pdf_version_t version);
	
	 void
	cairo_pdf_get_versions (cairo_pdf_version_t const **versions,
							int *num_versions);
	
	 const char *
	cairo_pdf_version_to_string (cairo_pdf_version_t version);
	
	 void
	cairo_pdf_surface_set_size (cairo_surface_t *surface,
		   double width_in_points,
		   double height_in_points);
	typedef enum _cairo_pdf_outline_flags {
		CAIRO_PDF_OUTLINE_FLAG_OPEN = 0x1,
		CAIRO_PDF_OUTLINE_FLAG_BOLD = 0x2,
		CAIRO_PDF_OUTLINE_FLAG_ITALIC = 0x4,
	} cairo_pdf_outline_flags_t;
	
	
	
	 int
	cairo_pdf_surface_add_outline (cairo_surface_t *surface,
			  int parent_id,
			  const char *utf8,
			  const char *link_attribs,
			  cairo_pdf_outline_flags_t flags);
	typedef enum _cairo_pdf_metadata {
		CAIRO_PDF_METADATA_TITLE,
		CAIRO_PDF_METADATA_AUTHOR,
		CAIRO_PDF_METADATA_SUBJECT,
		CAIRO_PDF_METADATA_KEYWORDS,
		CAIRO_PDF_METADATA_CREATOR,
		CAIRO_PDF_METADATA_CREATE_DATE,
		CAIRO_PDF_METADATA_MOD_DATE,
	} cairo_pdf_metadata_t;
	
	 void
	cairo_pdf_surface_set_metadata (cairo_surface_t *surface,
		cairo_pdf_metadata_t metadata,
									const char *utf8);
	
	 void
	cairo_pdf_surface_set_page_label (cairo_surface_t *surface,
									  const char *utf8);
	
	 void
	cairo_pdf_surface_set_thumbnail_size (cairo_surface_t *surface,
			  int width,
			  int height);
	




	typedef enum _cairo_svg_version {
		CAIRO_SVG_VERSION_1_1,
		CAIRO_SVG_VERSION_1_2
	} cairo_svg_version_t;
	typedef enum _cairo_svg_unit {
		CAIRO_SVG_UNIT_USER = 0,
		CAIRO_SVG_UNIT_EM,
		CAIRO_SVG_UNIT_EX,
		CAIRO_SVG_UNIT_PX,
		CAIRO_SVG_UNIT_IN,
		CAIRO_SVG_UNIT_CM,
		CAIRO_SVG_UNIT_MM,
		CAIRO_SVG_UNIT_PT,
		CAIRO_SVG_UNIT_PC,
		CAIRO_SVG_UNIT_PERCENT
	} cairo_svg_unit_t;
	
		cairo_surface_t *
	cairo_svg_surface_create (const char *filename,
			double width_in_points,
			double height_in_points);
	
		cairo_surface_t *
	cairo_svg_surface_create_for_stream (cairo_write_func_t write_func,
				void *closure,
				double width_in_points,
				double height_in_points);
	
		void
	cairo_svg_surface_restrict_to_version (cairo_surface_t *surface,
				cairo_svg_version_t version);
	
		void
	cairo_svg_get_versions (cairo_svg_version_t const **versions,
							int *num_versions);
	
		const char *
	cairo_svg_version_to_string (cairo_svg_version_t version);
	
		void
	cairo_svg_surface_set_document_unit (cairo_surface_t *surface,
				cairo_svg_unit_t unit);
	
		cairo_svg_unit_t
	cairo_svg_surface_get_document_unit (cairo_surface_t *surface);
	
]]

return cr

