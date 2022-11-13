
#ifndef QTWIDGETTESTLIB_API_H
#define QTWIDGETTESTLIB_API_H

#ifdef QTWIDGETTESTLIB_STATIC_DEFINE
#  define QTWIDGETTESTLIB_API
#  define QTWIDGETTESTLIB_NO_EXPORT
#else
#  ifndef QTWIDGETTESTLIB_API
#    ifdef qtwidgettestlib_EXPORTS
        /* We are building this library */
#      define QTWIDGETTESTLIB_API __attribute__((visibility("default")))
#    else
        /* We are using this library */
#      define QTWIDGETTESTLIB_API __attribute__((visibility("default")))
#    endif
#  endif

#  ifndef QTWIDGETTESTLIB_NO_EXPORT
#    define QTWIDGETTESTLIB_NO_EXPORT __attribute__((visibility("hidden")))
#  endif
#endif

#ifndef QTWIDGETTESTLIB_DEPRECATED
#  define QTWIDGETTESTLIB_DEPRECATED __attribute__ ((__deprecated__))
#endif

#ifndef QTWIDGETTESTLIB_DEPRECATED_EXPORT
#  define QTWIDGETTESTLIB_DEPRECATED_EXPORT QTWIDGETTESTLIB_API QTWIDGETTESTLIB_DEPRECATED
#endif

#ifndef QTWIDGETTESTLIB_DEPRECATED_NO_EXPORT
#  define QTWIDGETTESTLIB_DEPRECATED_NO_EXPORT QTWIDGETTESTLIB_NO_EXPORT QTWIDGETTESTLIB_DEPRECATED
#endif

#if 0 /* DEFINE_NO_DEPRECATED */
#  ifndef QTWIDGETTESTLIB_NO_DEPRECATED
#    define QTWIDGETTESTLIB_NO_DEPRECATED
#  endif
#endif

#endif /* QTWIDGETTESTLIB_API_H */
