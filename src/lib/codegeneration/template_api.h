/*
 * SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
 *
 * SPDX-License-Identifier: EUPL-1.2
 *
 */
 
#ifndef @target_id @_TEMPLATE_API_H
#define @target_id @_TEMPLATE_API_H

#include <@target@/@target@_export.h>

#ifdef @target_id @_STATIC_DEFINE
#define @target_id @_TEMPLATE_API
#else
#ifndef @target_id @_TEMPLATE_API
#ifdef @target_id @_EXPORTS
/* We are building this library */
#define @target_id @_TEMPLATE_API __attribute__((visibility("default")))
#else
/* We are using this library */
#define @target_id @_TEMPLATE_API __attribute__((visibility("default")))
#endif
#endif

#endif

#endif
